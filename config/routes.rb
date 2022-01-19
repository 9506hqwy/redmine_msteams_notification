# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  resources :projects do
    post '/msteams_notification/test', to: 'msteams_destination#test', format: false
    put '/msteams_notification', to: 'msteams_destination#update', format: false
  end
end
