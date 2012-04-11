require 'test_helper'

class ShortUrlTest < Test::Unit::TestCase

  should "raise an exception if the api_key is nil" do
    SignalApi.api_key = nil
    assert_raise SignalApi::InvalidApiKeyException do
      SignalApi::ShortUrl.create("http://www.google.com", "ix.ly")
    end
  end

  should "raise an exception if the api_key is blank" do
    SignalApi.api_key = '   '
    assert_raise SignalApi::InvalidApiKeyException do
      SignalApi::ShortUrl.create("http://www.google.com", "ix.ly")
    end
  end

end
