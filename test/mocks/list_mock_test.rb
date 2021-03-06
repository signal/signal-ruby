require 'test_helper'
require 'signal_api/mocks/list'

class ListMockTest < Test::Unit::TestCase

  def setup
    SignalApi::List.clear_mock_data
  end

  should "be able to mock create_subscription" do
    assert_equal 0, SignalApi::List.mock_method_calls.values.flatten.length

    list = SignalApi::List.new(1)
    list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212'), { :source_campaign_id => 2 })

    assert_equal 1, SignalApi::List.mock_method_calls[:create_subscription].last[:list_id]
    assert_equal "SMS", SignalApi::List.mock_method_calls[:create_subscription].last[:subscription_type]
    assert_equal "3125551212", SignalApi::List.mock_method_calls[:create_subscription].last[:contact].mobile_phone
    assert_equal 2, SignalApi::List.mock_method_calls[:create_subscription].last[:options][:source_campaign_id]
  end

  should "be able to mock destroy_subscription" do
    assert_equal 0, SignalApi::List.mock_method_calls.values.flatten.length

    list = SignalApi::List.new(1)
    list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212'))

    assert_equal 1, SignalApi::List.mock_method_calls[:destroy_subscription].last[:list_id]
    assert_equal "SMS", SignalApi::List.mock_method_calls[:destroy_subscription].last[:subscription_type]
    assert_equal "3125551212", SignalApi::List.mock_method_calls[:destroy_subscription].last[:contact].mobile_phone
  end

end
