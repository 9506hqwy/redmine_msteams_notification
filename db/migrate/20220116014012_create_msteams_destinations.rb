# frozen_string_literal: true

if ActiveRecord::VERSION::MAJOR >= 5
  migration = ActiveRecord::Migration[4.2]
else
  migration = ActiveRecord::Migration
end

class CreateMsteamsDestinations < migration
  def change
    create_table :msteams_destinations do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :url
      t.string :format
    end
  end
end
