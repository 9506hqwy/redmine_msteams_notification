# frozen_string_literal: true

module RedmineMsteamsNotification
  module CustomFieldPatch
    def self.prepended(base)
      base.class_eval do
        has_many :destination_for_mention_ids,
                 class_name: :MsteamsDestination,
                 foreign_key: :mention_id_field_id,
                 dependent: :restrict_with_exception
      end
    end
  end
end

CustomField.prepend RedmineMsteamsNotification::CustomFieldPatch
