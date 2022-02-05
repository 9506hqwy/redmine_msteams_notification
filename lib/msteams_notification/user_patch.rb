# frozen_string_literal: true

module RedmineMsteamsNotification
  module UserPatch
    def msteams_mentioned_enable?(destination)
      return false if destination.blank?
      return true if destination.user_mentioned_field_id.blank?

      values = CustomValue.where(customized_type: :Principal, # Not :User
                                 customized_id: id,
                                 custom_field_id: destination.user_mentioned_field_id)
      value = values.first
      return destination.user_mentioned_field.default_value == '1' if value.blank?

      value.value == '1'
    end

    def msteams_mention_id(destination)
      return mail if destination.blank?
      return mail if destination.mention_id_field_id.blank?

      values = CustomValue.where(customized_type: :Principal, # Not :User
                                 customized_id: id,
                                 custom_field_id: destination.mention_id_field_id)
      value = values.first
      return nil if value.blank?
      return nil if value.value.blank?

      value.value
    end
  end
end

User.prepend RedmineMsteamsNotification::UserPatch
