class WebhookController < ApplicationController
  def index
    render json: { message: 'Hello, webhook!' }
  end
end
