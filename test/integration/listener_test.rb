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
      .with(body: /#15 was created. \(John Smith\)/)

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

  def test_issue_edit_subject
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /#6 was updated. \(Redmine Admin\)/)

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

  def test_issue_edit_assigned_to_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"User Misc <- Redmine Admin\"/)

    issue = issues(:issues_006)
    issue.assigned_to_id = 1
    issue.save!

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          assigned_to_id: "8"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_project_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Project\",\"value\":\"eCookbook <- Private child of eCookbook\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          project_id: "1"
        }
      })

    assert_not_requested(hook)
  end

  def test_issue_edit_tracker_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Tracker\",\"value\":\"Feature request <- Bug\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          tracker_id: "2"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_priority_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Priority\",\"value\":\"Normal <- Low\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          priority_id: "5"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_status_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Status\",\"value\":\"Assigned <- New\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          status_id: "2"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_start_date
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Start date\",\"value\":\"\d{2}\/\d{2}\/\d{4} <- \d{2}\/\d{2}\/\d{4}\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          start_date: "2022-01-01"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_due_date
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Due date\",\"value\":\"\d{2}\/\d{2}\/\d{4} <- \d{2}\/\d{2}\/\d{4}\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          due_date: "2023-01-01"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_assigned_to_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"User Misc <- Redmine Admin\"/)

    issue = issues(:issues_006)
    issue.assigned_to_id = 1
    issue.save!

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: issue.id,
        issue: {
          assigned_to_id: "8"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_project_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Project\",\"value\":\"eCookbook <- Private child of eCookbook\"/)

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: 6,
        issue: {
          project_id: "1"
        }
      })

    assert_not_requested(hook)
  end

  def test_issue_bulk_edit_tracker_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Tracker\",\"value\":\"Feature request <- Bug\"/)

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: 6,
        issue: {
          tracker_id: "2"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_priority_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Priority\",\"value\":\"Normal <- Low\"/)

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: 6,
        issue: {
          priority_id: "5"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_status_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Status\",\"value\":\"Assigned <- New\"/)

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: 6,
        issue: {
          status_id: "2"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_start_date
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Start date\",\"value\":\"\d{2}\/\d{2}\/\d{4} <- \d{2}\/\d{2}\/\d{4}\"/)

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: 6,
        issue: {
          start_date: "2022-01-01"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_due_date
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Due date\",\"value\":\"\d{2}\/\d{2}\/\d{4} <- \d{2}\/\d{2}\/\d{4}\"/)

    log_user('admin', 'admin')

    post(
      '/issues/bulk_update',
      params: {
        id: 6,
        issue: {
          due_date: "2023-01-01"
        }
      })

    assert_requested(hook)
  end

  def test_wiki_edit
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /Wiki was created. \(John Smith\)/)

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
