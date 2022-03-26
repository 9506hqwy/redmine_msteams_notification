# frozen_string_literal: true

module RedmineMsteamsNotification
  class Listener < Redmine::Hook::Listener
    include Rails.application.routes.url_helpers
    include ApplicationHelper
    include CustomFieldsHelper

    def controller_issues_new_after_save(context)
      issue = context[:issue]
      return if issue.is_private
      return unless enable?(issue.project)

      summary = l(:issue_added_summary)
      title = sprintf('#%d %s (%s)', issue.id, l(:issue_added_title), issue.author.name)
      text = issue.event_title
      issue_url = object_url(issue)

      card  = issue.project.msteams_destination.card_class
      message = card.new(summary, title, text)
      facts = new_facts(issue, message, issue.author)

      message.add_open_uri(l(:msteams_card_action_open), issue_url)
      message.add_section(nil, nil, facts)
      message.add_section(nil, link_to(issue_url), nil)

      Rails.logger.debug(message.get_json)

      send_message(message, issue.project.msteams_destination)
    end

    def controller_issues_edit_after_save(context)
      issue = context[:issue]
      return if issue.is_private
      return unless enable?(issue.project)

      journal = context[:journal]
      return if journal.private_notes?

      summary = l(:issue_edited_summary)
      title = sprintf('#%d %s (%s)', issue.id, l(:issue_edited_title), journal.user.name)
      text = journal.event_title
      journal_url = object_url(journal)

      card = issue.project.msteams_destination.card_class
      message = card.new(summary, title, text)
      facts = new_facts(issue, message, journal.user)

      message.add_open_uri(l(:msteams_card_action_open), journal_url)
      message.add_section(nil, nil, facts)
      message.add_section(nil, journal.event_description, nil)
      message.add_section(nil, link_to(journal_url), nil)

      Rails.logger.debug(message.get_json)

      send_message(message, issue.project.msteams_destination)
    end

    def controller_issues_bulk_edit_before_save(context)
      issue = context[:issue]
      return if issue.is_private
      return unless enable?(issue.project)

      summary = l(:issue_editing_summary)
      title = sprintf('#%d %s (%s)', issue.id, l(:issue_editing_title), User.current.name)
      text = issue.event_title
      issue_url = object_url(issue)

      card  = issue.project.msteams_destination.card_class
      message = card.new(summary, title, text)
      facts = new_facts(issue, message, issue.author)

      message.add_open_uri(l(:msteams_card_action_open), issue_url)
      message.add_section(nil, nil, facts)
      message.add_section(nil, link_to(issue_url), nil)

      Rails.logger.debug(message.get_json)

      send_message(message, issue.project.msteams_destination)
    end

    def controller_wiki_edit_after_save(context)
      page = context[:page]
      return unless enable?(page.project)

      author = page.content.author

      summary = l(:wiki_edited_summary)
      summary = l(:wiki_added_summary) if page.content.version == 1
      title = sprintf('%s %s (%s)', page.title, l(:wiki_edited_title), author.name)
      title = sprintf('%s %s (%s)', page.title, l(:wiki_added_title), author.name) if page.content.version == 1
      text = page.event_title
      page_url = object_url(page)
      facts = {
        l(:field_author) => author.name,
      }

      card = page.project.msteams_destination.card_class
      message = card.new(summary, title, text)
      message.add_open_uri(l(:msteams_card_action_open), page_url)
      message.add_section(nil, nil, facts)
      message.add_section(nil, link_to(page_url), nil)

      Rails.logger.debug(message.get_json)

      send_message(message, page.project.msteams_destination)
    end

    private

    def enable?(project)
      return false unless project.module_enabled?(:msteams_notification)
      return false unless project.msteams_destination

      return project.msteams_destination.url.present?
    end

    def find_attr_old_value(issue, property)
      key = property_key(property)
      # for after save
      old_value = issue.previous_changes[key]&.first
      # for before save
      old_value ||= issue.changed_attributes[key]
      return nil unless old_value

      case property
      when 'assigned_to'
        return Principal.find_by_id(old_value)
      when 'due_date', 'start_date'
        return old_value
      when 'priority'
        return IssuePriority.find(old_value)
      when 'project'
        return Project.find_by_id(old_value)
      when 'status'
        return IssueStatus.find_by_id(old_value)
      when 'tracker'
        return Tracker.find_by_id(old_value)
      end

      nil
    end

    def format_attr_value(property, value)
      case property
      when 'due_date', 'start_date'
        return format_date(value)
      end

      return value.to_s
    end

    def link_to(url)
      "[#{url}](#{url})"
    end

    def mention_assigned_to?(issue, reporter)
      return false unless issue.assigned_to
      return false if issue.assigned_to.is_a?(Group)
      return false if issue.assigned_to == reporter
      return false unless issue.assigned_to.msteams_mentioned_enable?(issue.project.msteams_destination)

      issue.assigned_to.active?
    end

    def mention_previous_assignee?(issue, assignee, reporter)
      return false unless assignee
      return false if assignee.is_a?(Group)
      return false if assignee == reporter
      return false unless assignee.msteams_mentioned_enable?(issue.project.msteams_destination)

      assignee.active?
    end

    def mention_author?(issue, reporter)
      return false if issue.author == reporter
      return false if issue.author == issue.assigned_to
      return false unless issue.author.msteams_mentioned_enable?(issue.project.msteams_destination)

      issue.author.active?
    end

    def new_facts(issue, message, reporter)
      author = issue.author.name
      if message.mention_available? && mention_author?(issue, reporter)
        key = message.add_mention_for(issue.project, issue.author)
        author = key if key
      end

      facts = {
        l(:field_author) => author,
      }

      unless issue.disabled_core_fields.include?(property_key('assigned_to'))
        assigned_to = issue.assigned_to.name if issue.assigned_to
        if message.mention_available? && mention_assigned_to?(issue, reporter)
          key = message.add_mention_for(issue.project, issue.assigned_to)
          assigned_to = key if key
        end

        old_assigned_to = find_attr_old_value(issue, 'assigned_to')
        if old_assigned_to
          if message.mention_available? && mention_previous_assignee?(issue, old_assigned_to, reporter)
            key = message.add_mention_for(issue.project, old_assigned_to)
            old_assigned_to = old_assigned_to.name
            old_assigned_to = key if key
          else
            old_assigned_to = old_assigned_to.name
          end
          facts[l(:field_assigned_to)] = "#{assigned_to} <- #{old_assigned_to}"
        else
          facts[l(:field_assigned_to)] = assigned_to
        end
      end

      %w(project tracker status priority start_date due_date).each do |attribute|
        next if issue.disabled_core_fields.include?(property_key(attribute))

        old_value = find_attr_old_value(issue, attribute)
        new_value = issue.send(attribute)
        if old_value
          facts[l_or_humanize(attribute, prefix: 'field_')] =
            "#{format_attr_value(attribute, new_value)} <- #{format_attr_value(attribute, old_value)}"
        else
          facts[l_or_humanize(attribute, prefix: 'field_')] = format_attr_value(attribute, new_value)
        end
      end

      issue.custom_field_values.each do |cv|
        if cv.required?
          cf = cv.custom_field
          if cf.roles.empty?
            old_value = cv.value_was unless cv.value == cv.value_was
            old_value = format_value(old_value, cf) if old_value
            if old_value.present?
              facts[cf.name] = "#{format_value(cv.value, cf)} <- #{old_value}"
            else
              facts[cf.name] = format_value(cv.value, cf)
            end
          end
        end
      end

      facts
    end

    def object_url(act)
      options = { protocol: Setting.protocol }
      if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
        host, port, path = $2, $4, $5
        options.merge!({
                         host: host,
                         port: port,
                         script_name: path,
                       })
      else
        options[:host] = Setting.host_name
      end

      url_for(act.event_url(options))
    end

    def property_key(property)
      case property
      when 'assigned_to', 'project', 'tracker', 'status', 'priority'
        "#{property}_id"
      else
        property
      end
    end

    def send_message(message, destination)
      message.send(destination.url, destination.skip_ssl_verify)
    rescue => e
      Rails.logger.error(e)
    end
  end
end
