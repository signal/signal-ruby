require 'test_helper'
require 'signal_api/mocks/contact'

class ContactMockTest < Test::Unit::TestCase

  def setup
    SignalApi::Contact.clear_mock_data
  end

  should "be able to mock save" do
    assert_equal 0, SignalApi::Contact.mock_method_calls.values.flatten.length

    contact = SignalApi::Contact.new('mobile_phone' => '3125551212', 'email_address' => 'bill.johnson@domain.com', 'first_name' => 'bill', 'last_name' => 'johnson', 'zip_code' => '60606')
    contact.save

    attributes = SignalApi::Contact.mock_method_calls[:save].last[:attributes]
    assert_equal '3125551212', attributes['mobile_phone']
    assert_equal 'bill.johnson@domain.com', attributes['email_address']
    assert_equal 'bill', attributes['first_name']
    assert_equal 'johnson', attributes['last_name']
    assert_equal '60606', attributes['zip_code']
  end

end
