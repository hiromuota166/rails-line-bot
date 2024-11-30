Rails.application.routes.draw do
  post '/webhook', to: 'line_bot#webhook'
end
