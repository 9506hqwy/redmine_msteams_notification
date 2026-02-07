# frozen_string_literal: true

class AddTextMaxLengthColumnToDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    add_column(:msteams_destinations, :text_max_length, :integer, default: 2048)
  end
end
