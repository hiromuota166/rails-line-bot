require 'net/http'
require 'uri'

class LineBotController < ApplicationController

  def webhook
    body = request.body.read

    events = JSON.parse(body)['events']
    events.each do |event|
      case event['type']
      when 'message'
        handle_message(event)
      end
    end

    head :ok
  end

  private

  def handle_message(event)
    message = event['message']
    reply_token = event['replyToken']

    if message['type'] == 'text'
      text = message['text']
      post = Post.create(title: text, content: text)
      if post.persisted?
        reply_message(reply_token, "新しい投稿を作成しました！\nTitle: #{post.title}\nContent: #{post.content}")
      else
        reply_message(reply_token, '投稿に失敗しました')
      end
    end
  end

  def reply_message(reply_token, text)
    uri = URI.parse('https://api.line.me/v2/bot/message/reply')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['LINE_CHANNEL_ACCESS_TOKEN']}"
    })

    request.body = {
      replyToken: reply_token,
      messages: [{ type: 'text', text: text }]
    }.to_json
  end
end
