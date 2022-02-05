# frozen_string_literal: true

module RedmineMsteamsNotification
  class Listener < Redmine::Hook::Listener
    include Rails.application.routes.url_helpers

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

    def link_to(url)
      "[#{url}](#{url})"
    end

    def mention_assigned_to?(issue, reporter)
      return false unless issue.assigned_to
      return false if issue.assigned_to.is_a?(Group)
      return false if issue.assigned_to == reporter

      issue.assigned_to.active?
    end

    def mention_author?(issue, reporter)
      return false if issue.author == reporter
      return false if issue.author == issue.assigned_to

      issue.author.active?
    end

    def new_facts(issue, message, reporter)
      author = issue.author.name
      if message.mention_available? && mention_author?(issue, reporter)
        key = message.add_mention_for(issue.project, issue.author)
        author = key if key
      end

      assigned_to = issue.assigned_to.name if issue.assigned_to
      if message.mention_available? && mention_assigned_to?(issue, reporter)
        key = message.add_mention_for(issue.project, issue.assigned_to)
        assigned_to = key if key
      end

      facts = {
        l(:field_author) => author.to_s,
        l(:field_project) => issue.project.name,
        l(:field_tracker) => issue.tracker.name,
        l(:field_assigned_to) => assigned_to.to_s,
        l(:field_status) => issue.status.to_s,
        l(:field_priority) => issue.priority.to_s,
      }

      issue.custom_field_values.each do |cv|
        if cv.required?
          cf = cv.custom_field
          if cf.roles.empty?
            facts[cf.name] = cv.value
          end
        end
      end

      facts
    end

    def object_url(act)
      url_for(act.event_url(protocol: Setting.protocol, host: Setting.host_name))
    end

    def send_message(message, destination)
      message.send(destination.url, destination.skip_ssl_verify)
    rescue => e
      Rails.logger.error(e)
    end
  end
end
