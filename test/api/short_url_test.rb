require 'test_helper'

class ShortUrlTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  should "be able to create a short URL for the given target URL" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/short_urls.xml', :content_type => 'application/xml', :status => ['201', 'Created'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<short-url>
  <slug>e25s</slug>
  <target-url>http://www.google.com</target-url>
  <created-at type="datetime">2012-04-10T16:07:50Z</created-at>
  <title nil="true"></title>
  <updated-at type="datetime">2012-04-10T16:07:50Z</updated-at>
  <domain-id type="integer">1</domain-id>
  <account-id type="integer">1</account-id>
  <id type="integer">121</id>
</short-url>
END
    short_url = SignalApi::ShortUrl.create("http://www.google.com", "ix.ly")
    assert_equal "http://ix.ly/e25s", short_url.short_url
    assert_equal "http://www.google.com", short_url.target_url
    assert_equal 121, short_url.id
    assert_equal "ix.ly", short_url.domain
  end

  should "raise an exception if the short URL cannot be created" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/short_urls.xml', :content_type => 'application/xml', :status => ['400', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<errors>
  <error>Slug can't be blank</error>
  <error>Slug is invalid</error>
  <error>The short URL domain is not available</error>
</errors>
END
    assert_raise SignalApi::ApiException do
      SignalApi::ShortUrl.create("http://www.google.com", "ix.ly")
    end
  end

end
