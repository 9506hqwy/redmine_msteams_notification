# frozen_string_literal: true

if ActiveRecord::VERSION::MAJOR >= 5
  Migration = ActiveRecord::Migration[4.2]
else
  Migration = ActiveRecord::Migration
end

class CreateMsteamsDestinations < Migration
  def change
    create_table :msteams_destinations do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :url
      t.string :format
    end
  end
end
