class LineBotController < ApplicationController

  def webhook
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    if !validate_signature(body, signature)
      head :bad_request
      return
    end

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
      reply_message(reply_token, "You said: #{message['text']}")
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

    http.request(request)
  end

  def validate_signature(body, signature)
    expected_signature = OpenSSL::HMAC.hexdigest('SHA256', ENV['LINE_CHANNEL_SECRET'], body)
    signature == expected_signature
  end
end
