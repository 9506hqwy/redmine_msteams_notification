# frozen_string_literal: true

class CreateMsteamsDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    create_table :msteams_destinations do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :url
      t.string :format
    end
  end
end
