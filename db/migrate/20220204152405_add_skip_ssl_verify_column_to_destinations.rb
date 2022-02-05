# frozen_string_literal: true

class AddSkipSslVerifyColumnToDestinations < RedmineMsteamsNotification::Utils::Migration
  def change
    add_column(:msteams_destinations, :skip_ssl_verify, :boolean)
  end
end
