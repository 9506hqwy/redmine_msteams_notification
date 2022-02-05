# frozen_string_literal: true

class AddMentionIdFieldColumnToDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    add_reference(:msteams_destinations, :mention_id_field)

    # Use `add_forign_key` because `to_table` at `add_reference` is not work in RAILS4.
    add_foreign_key(:msteams_destinations, :custom_fields, column: :mention_id_field_id)
  end
end
