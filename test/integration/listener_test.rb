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
           :watchers,
           :wikis,
           :wiki_contents,
           :wiki_pages,
           :workflows,
           :msteams_destinations

  def setup
    WebMock.enable!
    stub_request(:post, 'https://localhost/test')

    project = Project.find(5)
    project.enable_module!(:msteams_notification)
    project.enable_module!(:wiki)

    project.msteams_destination.mention_id_field_id = nil
    project.msteams_destination.user_mentioned_field_id = nil
    project.msteams_destination.save!
  end

  def teardown
    WebMock.reset_executed_requests!
    WebMock.disable!
  end

  def test_issue_add
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /#\d+ was created. \(John Smith\)/)

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

  def test_issue_add_hidden_author
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Author\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['author']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_assigned_to
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['assigned_to']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_project
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Project\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['project']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_tracker
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Tracker\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['tracker']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_status
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Status\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['status']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_priority
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Priority\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['priority']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_start_date
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Start date\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['start_date']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_due_date
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Due date\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['due_date']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_watcher
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Watcher\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['watcher']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_hidden_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Mentioned\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['mentioned']
    project.msteams_destination.save!

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
    assert_not_requested(hook_hidden)
  end

  def test_issue_add_mention_assigned_to
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"<at>miscuser8<\/at>\"/)

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

  def test_issue_add_mention_not_assigned_to
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"John Smith\"/)

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
            assigned_to_id: 2
          }
        })
    end

    assert_requested(hook)
  end

  def test_issue_add_mention_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Mentioned\",\"value\":\"<at>admin<\/at>\"/)

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
            assigned_to_id: 8,
            description: "@admin",
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

  def test_issue_edit_subject_mention_author
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Author\",\"value\":\"<at>jsmith<\/at>\"/)

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

  def test_issue_edit_subject_watcher
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Watcher\",\"value\":\"<at>dlopper<\/at>\"/)

    issue = Issue.find(6)
    issue.watcher_users << User.find(3)

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

  def test_issue_edit_description_mention_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Mentioned\",\"value\":\"<at>admin<\/at>\"/)

    log_user('jsmith', 'jsmith')

    put(
      '/issues/6',
      params: {
        issue: {
          description: "@admin"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_notes_mention_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"text\":\"<at>admin<\/at>\"/)

    log_user('jsmith', 'jsmith')

    put(
      '/issues/6',
      params: {
        issue: {
          notes: "@admin"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_notes_mention_not_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"text\":\"@admina\"/)

    log_user('jsmith', 'jsmith')

    put(
      '/issues/6',
      params: {
        issue: {
          notes: "@admina"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_assigned_to_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"<at>miscuser8<\/at> from Redmine Admin\"/)

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

  def test_issue_edit_previous_assigned_to_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"John Smith from <at>admin<\/at>\"/)

    issue = issues(:issues_006)
    issue.assigned_to_id = 1
    issue.save!

    log_user('jsmith', 'jsmith')

    put(
      '/issues/6',
      params: {
        issue: {
          assigned_to_id: "2"
        }
      })

    assert_requested(hook)
  end

  def test_issue_edit_project_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Project\",\"value\":\"eCookbook from Private child of eCookbook\"/)

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
      .with(body: /\"title\":\"Tracker\",\"value\":\"Feature request from Bug\"/)

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
      .with(body: /\"title\":\"Priority\",\"value\":\"Normal from Low\"/)

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
      .with(body: /\"title\":\"Status\",\"value\":\"Assigned from New\"/)

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
      .with(body: /\"title\":\"Start date\",\"value\":\"\d{2}\/\d{2}\/\d{4} from \d{2}\/\d{2}\/\d{4}\"/)

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
      .with(body: /\"title\":\"Due date\",\"value\":\"\d{2}\/\d{2}\/\d{4} from \d{2}\/\d{2}\/\d{4}\"/)

    log_user('admin', 'admin')

    put(
      '/issues/6',
      params: {
        issue: {
          due_date: "3000-01-01"
        }
      })

    assert_requested(hook)
  end

  def test_issue_bulk_edit_assigned_to_id
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Assignee\",\"value\":\"<at>miscuser8<\/at> from Redmine Admin\"/)

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
      .with(body: /\"title\":\"Project\",\"value\":\"eCookbook from Private child of eCookbook\"/)

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
      .with(body: /\"title\":\"Tracker\",\"value\":\"Feature request from Bug\"/)

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
      .with(body: /\"title\":\"Priority\",\"value\":\"Normal from Low\"/)

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
      .with(body: /\"title\":\"Status\",\"value\":\"Assigned from New\"/)

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
      .with(body: /\"title\":\"Start date\",\"value\":\"\d{2}\/\d{2}\/\d{4} from \d{2}\/\d{2}\/\d{4}\"/)

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
      .with(body: /\"title\":\"Due date\",\"value\":\"\d{2}\/\d{2}\/\d{4} from \d{2}\/\d{2}\/\d{4}\"/)

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

  def test_wiki_edit_hidden_author
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Author\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['author']
    project.msteams_destination.save!

    log_user('jsmith', 'jsmith')

    put(
      '/projects/private-child/wiki/Wiki',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_requested(hook)
    assert_not_requested(hook_hidden)
  end

  def test_wiki_edit_hidden_watcher
    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Watcher\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['watcher']
    project.msteams_destination.save!

    log_user('jsmith', 'jsmith')

    put(
      '/projects/private-child/wiki/Wiki',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_requested(hook)
    assert_not_requested(hook_hidden)
  end

  def test_wiki_edit_hidden_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
    hook_hidden = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Mentioned\",/)

    project = Project.find(5)
    project.msteams_destination.hidden_items = ['mentioned']
    project.msteams_destination.save!

    log_user('jsmith', 'jsmith')

    put(
      '/projects/private-child/wiki/Wiki',
      params: {
        content: {
          text: "wiki content"
        }
      })

    assert_requested(hook)
    assert_not_requested(hook_hidden)
  end

  def test_wiki_edit_watcher
    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Watcher\",\"value\":\"<at>dlopper<\/at>\"/)

    page = Wiki.find(5).find_or_new_page('')
    page.save!
    page.watcher_users << User.find(3)

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

  def test_wiki_edit_mention_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Mentioned\",\"value\":\"<at>admin<\/at>\"/)

    log_user('jsmith', 'jsmith')

    put(
      '/projects/private-child/wiki/Wiki',
      params: {
        content: {
          text: "@admin"
        }
      })

    assert_requested(hook)
  end

  def test_wiki_edit_mention_not_mentioned
    skip unless Redmine::VERSION::MAJOR >= 5

    hook = stub_request(:post, 'https://localhost/test')
      .with(body: /\"title\":\"Mentioned\",\"value\":\"Redmine Admin\"/)

    log_user('admin', 'admin')

    put(
      '/projects/private-child/wiki/Wiki',
      params: {
        content: {
          text: "@admin"
        }
      })

    assert_requested(hook)
  end
end
