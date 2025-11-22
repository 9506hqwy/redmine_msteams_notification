# frozen_string_literal: true

class ChangeUrlLimitInDestinations < RedmineMsteamsNotification::Utils::Migration
  def up
    change_column(:msteams_destinations, :url, :text)
  end

  def down
    change_column(:msteams_destinations, :url, :string)
  end
end
