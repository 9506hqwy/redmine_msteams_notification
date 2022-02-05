# frozen_string_literal: true

require 'webmock'
require File.expand_path('../../test_helper', __FILE__)

# user:2   ----->  project:1
#            role:1
#          ----->  project:2  -----> destination:1
#            role:2
#          ----->  project:5  -----> destination:2
#            role:1

class MsteamsDestinationControllerTest < Redmine::ControllerTest
  include Redmine::I18n
  include WebMock::API

  fixtures :custom_fields,
           :email_addresses,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :msteams_destinations

  def setup
    @request.session[:user_id] = 2

    role = Role.find(1)
    role.add_permission! :edit_msteams_notification
  end

  def test_test_adaptivecard
    WebMock.enable!

    project = Project.find(5)
    project.enable_module!(:msteams_notification)

    project.msteams_destination.url = 'https://localhost/'
    project.msteams_destination.format = 'AdaptiveCard'
    project.msteams_destination.skip_ssl_verify = false
    project.msteams_destination.save!

    stub_request(:post, 'https://localhost/')

    post :test, params: {
      project_id: project.id
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]
  ensure
    WebMock.disable!
  end

  def test_test_messagecard
    WebMock.enable!

    project = Project.find(5)
    project.enable_module!(:msteams_notification)

    project.msteams_destination.url = 'https://localhost/'
    project.msteams_destination.format = 'MessageCard'
    project.msteams_destination.skip_ssl_verify = true
    project.msteams_destination.save!

    stub_request(:post, 'https://localhost/')

    post :test, params: {
      project_id: project.id
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]
  ensure
    WebMock.disable!
  end

  def test_test_failed
    project = Project.find(5)
    project.enable_module!(:msteams_notification)

    project.msteams_destination.url = 'http://localhost/'
    project.msteams_destination.save!

    post :test, params: {
      project_id: project.id
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
  end

  def test_test_url_empty
    project = Project.find(5)
    project.enable_module!(:msteams_notification)

    project.msteams_destination.url = ''
    project.msteams_destination.save!

    post :test, params: {
      project_id: project.id
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_nil flash[:notice]
    assert_nil flash[:error]
  end

  def test_test_url_null
    project = Project.find(1)
    project.enable_module!(:msteams_notification)
    post :test, params: {
      project_id: project.id
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_nil flash[:notice]
    assert_nil flash[:error]
  end

  def test_update_create
    project = Project.find(1)
    project.enable_module!(:msteams_notification)
    put :update, params: {
      project_id: project.id,
      msteams_destination: '',
      msteams_format: '',
      # msteams_skip_ssl_verify: false,
      msteams_mention_id_field_id: '',
      msteams_user_mentioned_field_id: '',
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    assert_empty project.msteams_destination.url
    assert_empty project.msteams_destination.format
    assert_equal false, project.msteams_destination.skip_ssl_verify
    assert_nil project.msteams_destination.mention_id_field_id
  end

  def test_update_deny_permission
    project = Project.find(2)
    project.enable_module!(:msteams_notification)
    put :update, params: {
      project_id: project.id,
      msteams_destination: 'http://localhost/hook',
      msteams_format: 'MessageCard',
      # msteams_skip_ssl_verify: false,
      msteams_mention_id_field_id: '',
      msteams_user_mentioned_field_id: '',
    }

    assert_response 403
  end

  def test_update_update
    project = Project.find(5)
    project.enable_module!(:msteams_notification)
    put :update, params: {
      project_id: project.id,
      msteams_destination: 'http://localhost/hook',
      msteams_format: 'MessageCard',
      msteams_skip_ssl_verify: true,
      msteams_mention_id_field_id: '1',
      msteams_user_mentioned_field_id: '2',
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/msteams_notification"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    assert_equal 'http://localhost/hook', project.msteams_destination.url
    assert_equal 'MessageCard', project.msteams_destination.format
    assert_equal true, project.msteams_destination.skip_ssl_verify
    assert_equal 1, project.msteams_destination.mention_id_field_id
    assert_equal 2, project.msteams_destination.user_mentioned_field_id
  end
end
