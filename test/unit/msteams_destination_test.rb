# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MsteamsDestinationTest < ActiveSupport::TestCase
  fixtures :projects,
           :msteams_destinations

  def test_create
    p = projects(:projects_001)

    d = MsteamsDestination.new
    d.project = p
    d.url = nil
    d.format = 'AdaptiveCard'
    d.save!

    d.reload
    assert_equal p.id, d.project_id
    assert_nil d.url
    assert_equal 'AdaptiveCard', d.format
    assert_equal RedmineMsteamsNotification::AdaptiveCard, d.card_class
  end

  def test_update
    p = projects(:projects_002)

    d = p.msteams_destination
    d.url = 'http://localhost/hooks'
    d.format = 'MessageCard'
    d.save!

    d.reload
    assert_equal 'http://localhost/hooks', d.url
    assert_equal 'MessageCard', d.format
    assert_equal RedmineMsteamsNotification::MessageCard, d.card_class
  end
end
