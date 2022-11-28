# frozen_string_literal: true

module RedmineMsteamsNotification
  module ProjectsHelperPatch
    def project_settings_tabs
      action = {
        name: 'msteams_notification',
        controller: :msteams_destination,
        action: :update,
        partial: 'msteams_destination/show',
        label: :msteams_notification,
      }

      tabs = super
      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end
end

Rails.application.config.after_initialize do
  ProjectsController.send(:helper, RedmineMsteamsNotification::ProjectsHelperPatch)
end
