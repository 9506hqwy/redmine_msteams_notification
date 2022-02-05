# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :custom_fields,
           :custom_values,
           :users,
           :msteams_destinations

  def test_msteams_mentin_id_cf_nil
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    id = u.msteams_mention_id(s)
    assert_nil id
  end

  def test_msteams_mentin_id_cf_value
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    v = CustomValue.new
    v.customized = u
    v.custom_field = s.mention_id_field
    v.value = 'test'
    v.save!

    id = u.msteams_mention_id(s)
    assert_equal 'test', id
  end

  def test_msteams_mentin_id_cf_value_nil
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    v = CustomValue.new
    v.customized = u
    v.custom_field = s.mention_id_field
    v.value = ''
    v.save!

    id = u.msteams_mention_id(s)
    assert_nil id
  end

  def test_msteams_mentin_id_mail
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_001)
    id = u.msteams_mention_id(s)
    assert_equal 'admin@somenet.foo', id
  end

  def test_msteams_mentin_id_nil
    u = users(:users_001)
    id = u.msteams_mention_id(nil)
    assert_equal 'admin@somenet.foo', id
  end
end
