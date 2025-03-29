# frozen_string_literal: true

class MsteamsDestination < RedmineMsteamsNotification::Utils::ModelBase
  belongs_to :mention_id_field, class_name: :CustomField
  belongs_to :project
  belongs_to :user_mentioned_field, class_name: :CustomField

  def card_class
    if format == 'MessageCard'
      RedmineMsteamsNotification::MessageCard
    else
      RedmineMsteamsNotification::AdaptiveCard
    end
  end

  def hidden_items
    v = read_attribute(:hidden_items)
    YAML.safe_load(v) if v
  end

  def hidden_items=(v)
    write_attribute(:hidden_items, v.to_yaml.to_s)
  end
end
