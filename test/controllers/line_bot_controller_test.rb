require "test_helper"

class LineBotControllerTest < ActionDispatch::IntegrationTest
  test "should get webhook" do
    get line_bot_webhook_url
    assert_response :success
  end
end
