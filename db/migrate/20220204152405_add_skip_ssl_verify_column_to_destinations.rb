# frozen_string_literal: true

if ActiveRecord::VERSION::MAJOR >= 5
  migration = ActiveRecord::Migration[4.2]
else
  migration = ActiveRecord::Migration
end

class AddSkipSslVerifyColumnToDestinations < migration
  def change
    add_column(:msteams_destinations, :skip_ssl_verify, :boolean)
  end
end
