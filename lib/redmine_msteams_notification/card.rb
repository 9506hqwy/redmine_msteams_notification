# frozen_string_literal: true

require 'net/http'
require 'json'

module RedmineMsteamsNotification
  class Card
    def get_json
      JSON.generate(message)
    end

    def mention_available?
      false
    end

    def send(url, skip_ssl_verify)
      uri = URI.parse(url)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = 'application/json'
      request.body = get_json

      conn = Net::HTTP.new(uri.host, uri.port)
      conn.use_ssl = uri.scheme == 'https'
      if skip_ssl_verify
        conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      conn.start do |http|
        http.request(request)
      end
    end
  end
end
