# frozen_string_literal: true

class ChangeUrlLimitInMsteamsDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    change_column :msteams_destinations, :url, :text
  end
end
