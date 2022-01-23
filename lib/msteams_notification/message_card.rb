# frozen_string_literal: true

require 'net/http'
require 'json'

module RedmineMsteamsNotification
  # https://docs.microsoft.com/ja-jp/outlook/actionable-messages/message-card-reference
  class MessageCard
    def initialize(summary, title, text=nil)
      @summary = summary
      @title = title
      @text = text
      @sections = []
      @actions = []
    end

    def add_open_uri(name, url)
      action = {
        '@type': 'OpenUri',
        name: name.to_s,
        targets: [
          {
            os: 'default',
            uri: url.to_s,
          },
        ],
      }
      @actions << action
    end

    def add_section(title=nil, text=nil, facts=nil)
      section = {}
      section[:startGroup] = true
      section[:title] = title.to_s if title
      section[:text] = text.to_s if text
      if facts
        section[:facts] = facts.map do |k, v|
          {
            name: k.to_s,
            value: v.to_s
          }
        end
      end
      @sections << section
    end

    def get_json
      JSON.generate(message)
    end

    def mention_available?
      false
    end

    def send(url)
      uri = URI.parse(url)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = 'application/json'
      request.body = get_json

      conn = Net::HTTP.new(uri.host, uri.port)
      conn.use_ssl = true
      conn.verify_mode = OpenSSL::SSL::VERIFY_NONE

      conn.start do |http|
        http.request(request)
      end
    end

    private

    def message
      msg = {}
      msg[:@type] = 'MessageCard'
      msg[:@context] = 'https://schema.org/extensions'
      msg[:summary] = @summary.to_s
      msg[:title] = @title.to_s
      msg[:text] = @text.to_s if @text
      msg[:sections] = @sections
      msg[:potentialAction] = @actions
      msg
    end
  end
end
