require "test_helper"

class ReadwiseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get readwise_index_url
    assert_response :success
  end
end
