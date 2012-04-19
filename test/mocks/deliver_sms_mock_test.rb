require 'test_helper'
require 'signal_api/mocks/deliver_sms'

class DeliverSmsTest < Test::Unit::TestCase

  def setup
    SignalApi::DeliverSms.clear_mock_data
  end

  should "be able to mock deliver" do
    assert_equal 0, SignalApi::DeliverSms.mock_method_calls.values.flatten.length

    message = SignalApi::DeliverSms.new("user_name", "password")
    message.deliver("3125551212", "this is a test message")

    assert_equal "user_name", SignalApi::DeliverSms.mock_method_calls[:deliver].last[:user_name]
    assert_equal "3125551212", SignalApi::DeliverSms.mock_method_calls[:deliver].last[:mobile_phone]
    assert_equal "this is a test message", SignalApi::DeliverSms.mock_method_calls[:deliver].last[:message]
  end

end
