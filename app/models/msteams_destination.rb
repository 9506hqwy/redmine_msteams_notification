# frozen_string_literal: true

class MsteamsDestination < RedmineMsteamsNotification::Utils::ModelBase
  belongs_to :mention_id_field, class_name: :CustomField
  belongs_to :project
  belongs_to :user_mentioned_field, class_name: :CustomField

  def card_class
    if format == 'AdaptiveCard'
      RedmineMsteamsNotification::AdaptiveCard
    else
      RedmineMsteamsNotification::MessageCard
    end
  end
end
