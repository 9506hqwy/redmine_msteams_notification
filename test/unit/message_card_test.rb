# frozen_string_literal: true

require 'json'
require File.expand_path('../../test_helper', __FILE__)

class MessageCardTest < ActiveSupport::TestCase
  def test_new
    m = RedmineMsteamsNotification::MessageCard.new 'summary', 'title'
    j = m.get_json
    assert_not_nil j

    r = JSON.parse(j)
    assert_equal 'MessageCard', r['@type']
    assert_equal 'https://schema.org/extensions', r['@context']
    assert_equal 'summary', r['summary']
    assert_equal 'title', r['title']
    assert_nil r['text']
    assert_empty r['sections']
    assert_empty r['potentialAction']
  end

  def test_add_open_uri
    m = RedmineMsteamsNotification::MessageCard.new 'summary', 'title', 'text'
    m.add_open_uri('uri', 'http://localhost')
    j = m.get_json
    assert_not_nil j

    r = JSON.parse(j)
    assert_equal 'MessageCard', r['@type']
    assert_equal 'https://schema.org/extensions', r['@context']
    assert_equal 'summary', r['summary']
    assert_equal 'title', r['title']
    assert_equal 'text', r['text']
    assert_empty r['sections']
    assert_equal 1, r['potentialAction'].length
    assert_equal 'uri', r['potentialAction'][0]['name']
    assert_equal 1, r['potentialAction'][0]['targets'].length
    assert_equal 'default', r['potentialAction'][0]['targets'][0]['os']
    assert_equal 'http://localhost', r['potentialAction'][0]['targets'][0]['uri']
  end

  def test_add_section
    m = RedmineMsteamsNotification::MessageCard.new 'summary', 'title'
    m.add_section('title', 'text', {a: 1, b: 2})
    j = m.get_json
    assert_not_nil j

    r = JSON.parse(j)
    assert_equal 'MessageCard', r['@type']
    assert_equal 'https://schema.org/extensions', r['@context']
    assert_equal 'summary', r['summary']
    assert_equal 'title', r['title']
    assert_nil r['text']
    assert_equal 1, r['sections'].length
    assert_equal 'title', r['sections'][0]['title']
    assert_equal 'text', r['sections'][0]['text']
    assert_equal 2, r['sections'][0]['facts'].length
    assert_equal 'a', r['sections'][0]['facts'][0]['name']
    assert_equal '1', r['sections'][0]['facts'][0]['value']
    assert_equal 'b', r['sections'][0]['facts'][1]['name']
    assert_equal '2', r['sections'][0]['facts'][1]['value']
    assert_empty r['potentialAction']
  end
end
