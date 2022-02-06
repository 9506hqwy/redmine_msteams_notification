# frozen_string_literal: true

module RedmineMsteamsNotification
  module ProjectsHelperPatch
    def msteams_notification_setting_tabs(tabs)
      action = {
        name: 'msteams_notification',
        controller: :msteams_destination,
        action: :update,
        partial: 'msteams_destination/show',
        label: :msteams_notification,
      }

      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end

  module ProjectsHelperPatch4
    include ProjectsHelperPatch

    def self.included(base)
      base.class_eval do
        alias_method_chain(:project_settings_tabs, :msteams_notification)
      end
    end

    def project_settings_tabs_with_msteams_notification
      msteams_notification_setting_tabs(project_settings_tabs_without_msteams_notification)
    end
  end

  module ProjectsHelperPatch5
    include ProjectsHelperPatch

    def project_settings_tabs
      msteams_notification_setting_tabs(super)
    end
  end
end

if ActiveSupport::VERSION::MAJOR >= 5
  ProjectsHelper.prepend RedmineMsteamsNotification::ProjectsHelperPatch5
else
  ProjectsHelper.include RedmineMsteamsNotification::ProjectsHelperPatch4
end
