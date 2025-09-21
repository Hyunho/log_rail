require "test_helper"

class Readwise::ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get readwise_articles_index_url
    assert_response :success
  end

  test "should get show" do
    get readwise_articles_show_url
    assert_response :success
  end
end
