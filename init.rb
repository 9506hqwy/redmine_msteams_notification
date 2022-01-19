# frozen_string_literal: true

require_dependency 'adaptive_card'
require_dependency 'hook_listener'
require_dependency 'message_card'
require_dependency 'projects_helper_patch'
require_dependency 'project_patch'

Redmine::Plugin.register :redmine_msteams_notification do
  name 'Redmine MSTeams Notification plugin'
  author '9506hqwy'
  description 'This is a MSTeams notification plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/9506hqwy/redmine_msteams_notification'
  author_url 'https://github.com/9506hqwy'

  project_module :msteams_notification do
    permission :edit_msteams_notification, {msteams_destination: [:test, :update]}
  end
end
