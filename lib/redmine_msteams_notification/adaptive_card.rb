# frozen_string_literal: true

module RedmineMsteamsNotification
  # https://adaptivecards.io/
  class AdaptiveCard < Card
    def initialize(summary, title, text)
      super()
      @sections = []
      @mentions = []
      @actions = []

      section = {}
      section[:type] = 'TextBlock'
      section[:size] = 'Large'
      section[:weight] = 'Bolder'
      section[:text] = title.to_s
      @sections << section

      if text
        section = {}
        section[:type] = 'TextBlock'
        section[:wrap] = true
        section[:isSubtle] = true
        section[:spacing] = 'None'
        section[:text] = text.to_s
        @sections << section
      end
    end

    def add_open_uri(name, url)
      action = {
        type: 'Action.OpenUrl',
        title: name.to_s,
        url: url.to_s
      }
      @actions << action
    end

    def add_mention(key, id, name)
      mention = {
        type: "mention",
        text: key.to_s,
        mentioned: {
          id: id.to_s,
          name: name.to_s
        }
      }
      @mentions << mention
    end

    def add_mention_for(project, user)
      id = user.msteams_mention_id(project.msteams_destination)
      return nil if id.blank?

      key = "<at>#{user.login}</at>"
      add_mention(key, id, user.name)
      key
    end

    def add_section(title, text, facts)
      if text
        section = {}
        section[:type] = 'TextBlock'
        section[:separator] = true
        section[:wrap] = true
        section[:text] = text.to_s
        @sections << section
      end

      if facts
        section = {}
        section[:type] = 'FactSet'
        section[:separator] = true
        section[:facts] = facts.map do |k, v|
          {
            title: k.to_s,
            value: v.to_s
          }
        end

        @sections << section
      end
    end

    def mention_available?
      true
    end

    private

    def message
      # https://adaptivecards.io/designer/
      # https://docs.microsoft.com/ja-jp/microsoftteams/platform/webhooks-and-connectors/how-to/connectors-using?tabs=PowerShell#send-adaptive-cards-using-an-incoming-webhook
      # https://docs.microsoft.com/ja-jp/microsoftteams/platform/task-modules-and-cards/cards/cards-format?tabs=adaptive-md%2Cconnector-html#user-mention-in-incoming-webhook-with-adaptive-cards
      content = {}
      content[:type] = 'AdaptiveCard'
      content[:body] = @sections
      content[:actions] = @actions
      content["$schema"] = 'http://adaptivecards.io/schema/adaptive-card.json'
      content[:version] = "1.3"
      content[:msteams] = {
        entities: @mentions,
        width: 'Full',
      }

      attachment = {}
      attachment[:contentType] = 'application/vnd.microsoft.card.adaptive'
      attachment[:content] = content

      msg = {}
      msg[:type] = 'message'
      msg[:attachments] = [attachment]
      msg
    end
  end
end
