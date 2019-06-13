require 'daimyo_bot'

class DaimyoBot
  class Oneshot
    def initialize(&b)
      b.call(self)
    end

    def notify_duolingo
      post_message text: "implement me!"
    end

    def web_client
      DaimyoBot.instance.send(:client).web_client
    end

    def post_message(channel: '#bot_dev', as_user: true, text: )
      web_client.chat_postMessage(channel: channel, text: text, as_user: true)
    end
  end
end
