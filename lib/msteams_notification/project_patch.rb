# frozen_string_literal: true

module RedmineMsteamsNotification
  module ProjectPatch
    def self.prepended(base)
      base.class_eval do
        has_one :msteams_destination, dependent: :destroy
      end
    end
  end
end

Project.prepend RedmineMsteamsNotification::ProjectPatch
