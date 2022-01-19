# frozen_string_literal: true

module RedmineMsteamsNotification
  module ProjectPacth
    def self.prepended(base)
      base.class_eval do
        has_one :msteams_destination, dependent: :destroy
      end
    end
  end
end

Project.prepend RedmineMsteamsNotification::ProjectPacth
