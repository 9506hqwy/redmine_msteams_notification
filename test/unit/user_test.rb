# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :custom_fields,
           :custom_values,
           :users,
           :msteams_destinations

  def test_msteams_user_mentioned_cf_default_1
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    c = custom_fields(:custom_fields_005)
    c.default_value = "1"
    c.save!

    assert u.msteams_mentioned_enable?(s)
  end

  def test_msteams_user_mentioned_cf_default_0
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    c = custom_fields(:custom_fields_005)
    c.default_value = "0"
    c.save!

    assert_not u.msteams_mentioned_enable?(s)
  end

  def test_msteams_user_mentioned_cf_value_1
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    v = CustomValue.new
    v.customized = u
    v.custom_field = s.user_mentioned_field
    v.value = '1'
    v.save!

    assert u.msteams_mentioned_enable?(s)
  end

  def test_msteams_user_mentioned_cf_value_0
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    v = CustomValue.new
    v.customized = u
    v.custom_field = s.user_mentioned_field
    v.value = '0'
    v.save!

    assert_not u.msteams_mentioned_enable?(s)
  end

  def test_msteams_user_mentioned_empty
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_001)
    assert u.msteams_mentioned_enable?(s)
  end

  def test_msteams_user_mentioned_nil
    u = users(:users_001)
    assert_not u.msteams_mentioned_enable?(nil)
  end

  def test_msteams_mention_id_cf_nil
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_002)

    id = u.msteams_mention_id(s)
    assert_nil id
  end

  def test_msteams_mention_id_cf_value
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

  def test_msteams_mention_id_cf_value_nil
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

  def test_msteams_mention_id_mail
    u = users(:users_001)
    s = msteams_destinations(:msteams_destinations_001)
    id = u.msteams_mention_id(s)
    assert_equal 'admin@somenet.foo', id
  end

  def test_msteams_mention_id_nil
    u = users(:users_001)
    id = u.msteams_mention_id(nil)
    assert_equal 'admin@somenet.foo', id
  end
end
