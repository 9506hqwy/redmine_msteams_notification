# frozen_string_literal: true

class AddUserMentionedFieldColumnToDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    add_reference(:msteams_destinations, :user_mentioned_field)
    add_foreign_key(:msteams_destinations, :custom_fields, column: :user_mentioned_field_id)
  end
end
