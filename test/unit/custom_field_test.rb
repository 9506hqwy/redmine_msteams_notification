# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class CustomFieldTest < ActiveSupport::TestCase
  fixtures :custom_fields,
           :msteams_destinations

  def test_destroy
    c = custom_fields(:custom_fields_001)
    assert_equal 0, c.destination_for_mention_ids.length
    assert c.destroy
  end

  def test_destroy_related
    c = custom_fields(:custom_fields_004)
    assert_equal 1, c.destination_for_mention_ids.length
    begin
      c.destroy
      assert false
    rescue ActiveRecord::DeleteRestrictionError
      assert true
    end

    c = custom_fields(:custom_fields_004)
    assert_not_nil c
  end
end
