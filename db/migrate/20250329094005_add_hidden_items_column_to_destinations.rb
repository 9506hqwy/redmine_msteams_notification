# frozen_string_literal: true

class AddHiddenItemsColumnToDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    add_column(:msteams_destinations, :hidden_items, :string)
  end
end
