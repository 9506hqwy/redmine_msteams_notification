# frozen_string_literal: true

require 'webmock'
require File.expand_path('../../test_helper', __FILE__)

# user:2   ----->  project:1
#            role:1
#          ----->  project:2  -----> destination:1
#            role:2
#          ----->  project:5  -----> destination:2
#            role:1

class HookListenerTest < Redmine::IntegrationTest
  include Redmine::I18n
  include WebMock::API

  fixtures :email_addresses,
           :enabled_modules,
           :enumerations,
           :issues,
           :issue_statuses,
           :member_roles,
           :members,
           :projects,
           :projects_trackers,
           :roles,
           :users,
           :trackers,
           :wikis,
           :wiki_contents,
           :wiki_pages,
           :msteams_destinations

  def setup
    WebMock.enable!
    stub_request(:post, 'https://localhost/test')

    project = Project.find(5)
    project.enable_module!(:msteams_notification)
    project.enable_module!(:wiki)
  end

  def teardown
    WebMock.reset_executed_requests!
    WebMock.disable!
  end

  def test_issue_add
    hook = stub_request(:post, 'https://localhost/test')

    log_user('jsmith', 'jsmith')

    new_record(Issue) do
      post(
        '/projects/private-child/issues',
        params: {
          issue: {
            tracker_id: '1',
            start_date: '2000-01-01',
            priority_id: "5",
            subject: "test issue",
            assigned_to_id: 8
          }
        })
    end

    assert_requested(hook)
  end

  def test_issue_edit
    hook = stub_request(:post, 'https://localhost/test')

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          subject: "test issue"
        }
      })

    assert_requested(hook)
  end

  def test_wiki_edit
    hook = stub_request(:post, 'https://localhost/test')

    log_user('jsmith', 'jsmith')

    put(
      '/projects/private-child/wiki/Wiki',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_requested(hook)
  end
end
