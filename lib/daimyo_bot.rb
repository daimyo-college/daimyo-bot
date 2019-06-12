# coding: utf-8
require 'slack-ruby-bot'
require 'async'

class DaimyoBot < SlackRubyBot::Bot
  help do
    title 'Daimyo Bot'
    desc '大名エンジニアカレッジのボット.'

    command 'ping' do
      desc 'Returns pong.'
    end

    command 'FGN|大名小' do
      desc '大名小の地図を教えてくれます'
    end
  end

  command 'ping' do |client, data, match|
    client.say(text: 'pong', channel: data.channel)
  end

  match /^(大名小|FGN)(の場所)?/ do |client, data, match|
    client.say(text: 'here: https://goo.gl/maps/tkQ1sNnLJp6MPYtx6', channel: data.channel)
  end
end
