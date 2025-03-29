# frozen_string_literal: true

module RedmineMsteamsNotification
  Notifiable = Struct.new(:name, :label) do
    def self.all
      notifications = []

      notifications << Notifiable.new('author', 'field_author')
      notifications << Notifiable.new('assigned_to', 'field_assigned_to')
      notifications << Notifiable.new('project', 'field_project')
      notifications << Notifiable.new('tracker', 'field_tracker')
      notifications << Notifiable.new('status', 'field_status')
      notifications << Notifiable.new('priority', 'field_priority')
      notifications << Notifiable.new('start_date', 'field_start_date')
      notifications << Notifiable.new('due_date', 'field_due_date')
      notifications << Notifiable.new('watcher', 'field_watcher')

      if Redmine::VERSION::MAJOR >= 5
        notifications << Notifiable.new('mentioned', 'field_mentioned')
      end

      notifications << Notifiable.new('action_open_url', 'label_link')

      notifications
    end

    def to_s
      name
    end
  end
end
