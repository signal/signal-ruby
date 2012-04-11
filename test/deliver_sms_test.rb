require 'test_helper'

class DeliverSmsTest < Test::Unit::TestCase

  def setup
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  should "be able to send a SMS message" do
    FakeWeb.register_uri(:post, uri, :status => ['200', 'Success'], :body => "Message ID: 7f9e82c0efbc012a166c0030482ef624")
    deliver_sms = SignalApi::DeliverSms.new('joe', 'joepassword')
    message_id = deliver_sms.deliver('3125551212', 'This is a test message')
    assert_equal "7f9e82c0efbc012a166c0030482ef624", message_id
  end

  should "handle API failures" do
    FakeWeb.register_uri(:post, uri, :status => ['500', 'Server Error'], :body => "Something bad happened")
    deliver_sms = SignalApi::DeliverSms.new('joe', 'joepassword')
    assert_raise SignalApi::ApiException do
      message_id = deliver_sms.deliver('3125551212', 'This is a test message')
    end
  end

  should "raise an error if the message is blank" do
    deliver_sms = SignalApi::DeliverSms.new('joe', 'joepassword')
    exception = assert_raise SignalApi::InvalidParameterException do
      deliver_sms.deliver('3125551212', nil)
    end
    assert_equal "A message must be provided", exception.message
  end

  should "raise an error if the mobile phone is blank" do
    deliver_sms = SignalApi::DeliverSms.new('joe', 'joepassword')
    exception = assert_raise SignalApi::InvalidParameterException do
      deliver_sms.deliver(nil, 'This is a test message')
    end
    assert_equal "An invalid mobile phone was specified: ", exception.message
  end

  should "raise an error if the mobile phone is invalid" do
    deliver_sms = SignalApi::DeliverSms.new('joe', 'joepassword')
    exception = assert_raise SignalApi::InvalidParameterException do
      deliver_sms.deliver("foo", 'This is a test message')
    end
    assert_equal "An invalid mobile phone was specified: foo", exception.message
  end

  should "raise an error if the username and password were not specified" do
    exception = assert_raise SignalApi::InvalidParameterException do
      SignalApi::DeliverSms.new('joe', nil)
    end
    assert_equal "username and password must be provided", exception.message
  end

  private

  def uri
    %r|https://joe:joepassword@api.imws.us/messages/send|
  end

end
