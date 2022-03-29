# frozen_string_literal: true

basedir = File.expand_path('../lib', __FILE__)
libraries =
  [
    'redmine_msteams_notification/utils',
    'redmine_msteams_notification/card',
    'redmine_msteams_notification/adaptive_card',
    'redmine_msteams_notification/custom_field_patch',
    'redmine_msteams_notification/listener',
    'redmine_msteams_notification/message_card',
    'redmine_msteams_notification/projects_helper_patch',
    'redmine_msteams_notification/project_patch',
    'redmine_msteams_notification/user_patch',
  ]

libraries.each do |library|
  require_dependency File.expand_path(library, basedir)
end

Redmine::Plugin.register :redmine_msteams_notification do
  name 'Redmine MSTeams Notification plugin'
  author '9506hqwy'
  description 'This is a MSTeams notification plugin for Redmine'
  version '0.6.0'
  url 'https://github.com/9506hqwy/redmine_msteams_notification'
  author_url 'https://github.com/9506hqwy'

  project_module :msteams_notification do
    permission :edit_msteams_notification, {msteams_destination: [:test, :update]}
  end
end
