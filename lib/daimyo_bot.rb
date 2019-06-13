# coding: utf-8
require 'slack-ruby-bot'
require 'async'
require 'redis'
require 'redis-namespace'

Redis.current = Redis.new(url: (ENV["REDIS_URL"] ||= 'redis://localhost:6379'))

class DaimyoBot < SlackRubyBot::Bot
  def self.brain
    @brain ||= Redis::Namespace.new(:daimyo_brain, redis: Redis.current)
  end

  def self.scoreboard
    @scoreboard ||= Redis::Namespace.new(:daimyo_scoreboard, redis: Redis.current)
  end

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

  match /(大名小|FGN)(の場所)?/ do |client, data, match|
    client.say(text: 'here: https://goo.gl/maps/tkQ1sNnLJp6MPYtx6', channel: data.channel)
  end

  match /([^\s+-]+)\+\+/ do |client, data, match|
    user = match[1]
    score = scoreboard.get(user) || 0
    score = score.to_i + 1
    scoreboard.set(user, score.to_s)
    client.say(text: "Incremented #{user}: #{score}pt", channel: data.channel)
  end

  match /([^\s+-]+)--/ do |client, data, match|
    user = match[1]
    score = scoreboard.get(user) || 0
    score = [0, score.to_i - 1].max
    scoreboard.set(user, score.to_s)
    client.say(text: "Decremented #{user}: #{score}pt", channel: data.channel)
  end
end
