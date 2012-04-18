require 'test_helper'
require 'signal_api/mocks/short_url'

class ShortUrlMockTest < Test::Unit::TestCase

  def setup
    SignalApi::ShortUrl.clear_mock_data
  end

  should "be able to mock create" do
    SignalApi::ShortUrl.create("http://www.google.com", "ix.ly")

    assert_equal "http://www.google.com", SignalApi::ShortUrl.mock_method_calls[:create].last[:target]
    assert_equal "ix.ly", SignalApi::ShortUrl.mock_method_calls[:create].last[:domain]
  end

end
