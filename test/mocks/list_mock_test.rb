require 'test_helper'
require 'signal_api/mocks/list'

class ListMockTest < Test::Unit::TestCase

  def setup
    SignalApi::List.clear_mock_data
  end

  should "be able to mock create_subscription" do
    list = SignalApi::List.new(1)
    list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212'), { :source_campaign_id => 2 })

    assert_equal 1, SignalApi::List.mock_method_calls[:create_subscription].last[:list_id]
    assert_equal "SMS", SignalApi::List.mock_method_calls[:create_subscription].last[:subscription_type]
    assert_equal "3125551212", SignalApi::List.mock_method_calls[:create_subscription].last[:contact].mobile_phone
    assert_equal 2, SignalApi::List.mock_method_calls[:create_subscription].last[:options][:source_campaign_id]
  end

end
