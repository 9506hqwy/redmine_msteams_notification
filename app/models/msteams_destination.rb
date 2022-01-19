# frozen_string_literal: true

class MsteamsDestination < ActiveRecord::Base
  belongs_to :project

  def card_class
    if format == 'AdaptiveCard'
      RedmineMsteamsNotification::AdaptiveCard
    else
      RedmineMsteamsNotification::MessageCard
    end
  end
end
