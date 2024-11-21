# frozen_string_literal: true

module RedmineMsteamsNotification
  module Utils
    if ActiveRecord::VERSION::MAJOR >= 5
      Migration = ActiveRecord::Migration[4.2]
    else
      Migration = ActiveRecord::Migration
    end

    if defined?(ApplicationRecord)
      # https://www.redmine.org/issues/38975
      ModelBase = ApplicationRecord
    else
      ModelBase = ActiveRecord::Base
    end
  end
end
