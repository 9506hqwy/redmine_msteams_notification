# frozen_string_literal: true

module RedmineMsteamsNotification
  module IssuePatch
    def self.prepended(base)
      base.class_eval do
        after_create_commit :msteams_notify_issues_new
      end
    end

    def msteams_notify_issues_new
      # Calls the hook before `add_auto_watcher`.
      # https://github.com/redmine/redmine/blob/5.1.0/app/models/issue.rb#L128
      #
      # Not includes the watcher that was added automatically.
      Redmine::Hook.call_hook(:redmine_msteams_notification_issues_new_after_save,
                              issue: self)
    end
  end
end

Issue.prepend RedmineMsteamsNotification::IssuePatch
