require 'net/http'
require 'uri'

class LineBotController < ApplicationController

  def webhook
    body = request.body.read
    # signature = request.env['HTTP_X_LINE_SIGNATURE']

    # logger.debug "Received signature: #{signature}"

    # if signature.nil?
    #   logger.error "Signature is nil"
    #   head :bad_request
    #   return
    # end

    # if !validate_signature(body, signature)
    #   logger.error "Signature validation failed"
    #   head :bad_request
    #   return
    # end

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

    logger.debug "Received message: #{message}"
    logger.debug "Reply token: #{reply_token}"

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

    response = http.request(request)

    logger.debug "LINE API response: #{response.code} - #{response.body}"

    if response.code.to_i != 200
      logger.error "Failed to send message: #{response.body}"
    end
  end

  # def validate_signature(body, signature)
  #   if signature.nil?
  #     logger.error "Signature is nil"
  #     return false
  #   end

  #   expected_signature = OpenSSL::HMAC.hexdigest('SHA256', ENV['LINE_CHANNEL_SECRET'], body)
  #   signature == expected_signature
  # end
end
