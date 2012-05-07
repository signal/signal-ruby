require 'test_helper'

class CouponGroupTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  should "be able to consume a coupon given a tag and phone number" do
    body = <<-END
<?xml version="1.0" encoding="UTF-8"?>
<coupon_code>AB1234</coupon_code>
END

    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/coupon_groups/consume_coupon.xml', :content_type => 'application/xml', :status => ['200', 'Ok'], :body => body)
    coupon_code = SignalApi::CouponGroup.consume_coupon("tag", "6843456782")
    assert_equal "AB1234", coupon_code
  end

  should "should throw exceptions for missing params" do
    assert_raise SignalApi::InvalidParameterException do 
      SignalApi::CouponGroup.consume_coupon(nil, "3125551212")
    end

    assert_raise SignalApi::InvalidParameterException do 
      SignalApi::CouponGroup.consume_coupon("asdfa", nil)
    end
  end

end
