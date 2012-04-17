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

  should "raise an exception if authentication failed" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/short_urls.xml', :content_type => 'application/xml', :status => ['401', 'Unauthorized'])
    assert_raise SignalApi::AuthFailedException do
      short_url = SignalApi::ShortUrl.create("http://www.google.com", "ix.ly")
    end
  end

end
