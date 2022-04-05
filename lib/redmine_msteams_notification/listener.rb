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
      facts = new_facts(issue, message, [issue.author])

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
      mentioned = [journal.user]
      facts = new_facts(issue, message, mentioned)
      description = mentioned_text(message, issue.project, journal, journal.event_description, mentioned)

      message.add_open_uri(l(:msteams_card_action_open), journal_url)
      message.add_section(nil, nil, facts)
      message.add_section(nil, description, nil)
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
      facts = new_facts(issue, message, [User.current])

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

      card = page.project.msteams_destination.card_class
      message = card.new(summary, title, text)

      facts = {
        l(:field_author) => author.name,
      }

      if Redmine::VERSION::MAJOR >= 5
        facts[l(:field_mentioned)] = notified_mentions(message, page.project, page.content, [author])
      end

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

    def link_to(url)
      "[#{url}](#{url})"
    end

    def mentioned_text(message, project, mentionable, text, mentioned)
      return text unless Redmine::VERSION::MAJOR >= 5

      mentionable.mentioned_users.to_a.each do |user|
        key = set_mentioned_key(message, project, user, mentioned)
        next unless key

        login = Regexp.escape(user.login)
        text = text.gsub(/@#{login}([^A-Za-z0-9_\-@\.])/, "#{key}\\1")
      end

      text
    end

    def new_facts(issue, message, mentioned)
      author = issue.author.name
      if issue.author != issue.assigned_to
        author = set_mentioned_key(message, issue.project, issue.author, mentioned)
      end

      facts = {
        l(:field_author) => author,
      }

      unless issue.disabled_core_fields.include?(property_key('assigned_to'))
        assigned_to = set_mentioned_key(message, issue.project, issue.assigned_to, mentioned)

        old_assigned_to = find_attr_old_value(issue, 'assigned_to')
        if old_assigned_to
          old_assigned_to = set_mentioned_key(message, issue.project, old_assigned_to, mentioned)
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
            "#{format_object(new_value, false)} <- #{format_object(old_value, false)}"
        else
          facts[l_or_humanize(attribute, prefix: 'field_')] = format_object(new_value, false)
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

      if Redmine::VERSION::MAJOR >= 5
        facts[l(:field_mentioned)] = notified_mentions(message, issue.project, issue, mentioned)
      end

      facts
    end

    def notified_mentions(message, project, mentionable, mentioned)
      users = mentionable.mentioned_users.to_a
      users.map! { |user| set_mentioned_key(message, project, user, mentioned) }
      users.compact.join(',')
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

    def set_mentioned_key(message, project, user, mentioned)
      if message.mention_available? && user_mention_enable?(project, user, mentioned)
        mentioned << user
        key = message.add_mention_for(project, user)
      end

      key || user&.name
    end

    def user_mention_enable?(project, user, mentioned)
      return false unless user
      return false if user.is_a?(Group)
      return false unless user.active?
      return false if mentioned.include?(user)

      user.msteams_mentioned_enable?(project.msteams_destination)
    end
  end
end
