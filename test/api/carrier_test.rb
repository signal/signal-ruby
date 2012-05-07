require 'test_helper'

class CarrierTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  should "be able to lookup a valid carrier" do
    body = <<-END
<?xml version="1.0" encoding="UTF-8"?>
<carrier>
  <name>AT&amp;T</name>
  <id type="integer">6</id>
</carrier>
END

    FakeWeb.register_uri(:get, SignalApi.base_uri + '/app/carriers/lookup/3125551212.xml', :content_type => 'application/xml', :status => ['200', 'Ok'], :body => body)
    carrier = SignalApi::Carrier.lookup('3125551212')
    assert_equal 6, carrier.id
    assert_equal "AT&T", carrier.name
  end

  should "should throw exceptions for missing params" do
    assert_raise SignalApi::InvalidParameterException do 
      SignalApi::Carrier.lookup(nil)
    end
  end

end
