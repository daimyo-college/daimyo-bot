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

  GIT_QUIZ = {
    1 => ["git init", "リポジトリを初期化する"],
    2 => ["git add file.rb", "ファイルをステージに追加する"],
    3 => ["git commit", "ステージのファイルからコミットを作る"],
    4 => ["git push origin test-1", "test-1ブランチをoriginにプッシュする"],
    5 => ["git pull --rebase origin master", "masterブランチをoriginから取得し、綺麗な形でローカルに反映させる"],
  }

  command 'git quiz' do |client, data, match|
    target = GIT_QUIZ.keys.sample
    brain.set('git_quiz', target)
    client.say(text: "このコマンドの意味は: #{GIT_QUIZ[target.to_i][0]}", channel: data.channel)
  end

  match /(answer|答え|回答)(\:|：)(.+)/ do |client, data, match|
    if target = brain.get('git_quiz')
      answer = match[3]
      real = GIT_QUIZ[target.to_i][1]

      if answer.strip == real
        user = client.web_client.users_info(user: data.user)

        score = scoreboard.get(user.name) || 0
        score = score.to_i + 10
        scoreboard.set(user.name, score.to_s)
        client.say(text: "正解！！", channel: data.channel)
        client.say(text: "#{user.name} さんに10pt進呈！ Current: #{score}pt", channel: data.channel)
      else
        client.say(text: "正解は: #{real}", channel: data.channel)
      end
      brain.set('git_quiz', nil)
    else
      client.say(text: "`git quiz` でクイズを出してください", channel: data.channel)
    end
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
