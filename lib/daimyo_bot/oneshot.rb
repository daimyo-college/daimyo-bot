require 'daimyo_bot'

class DaimyoBot
  class Oneshot
    def web_client
      DaimyoBot.instance.send(:client).web_client
    end

    def post_message(channel: '#random', as_user: true, text: )
      web_client.chat_postMessage(channel: channel, text: text, as_user: true)
    end
  end
end
