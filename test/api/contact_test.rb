require 'test_helper'
require 'signal_api/mocks/contact'

class ContactTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  should "be able to save a contact with lots of info" do
    contact = SignalApi::Contact.new('mobile_phone' => '3125551212', 'email_address' => 'bill.johnson@domain.com', 'first_name' => 'bill', 'last_name' => 'johnson', 'zip_code' => '60606')
    contact.save

    attributes = SignalApi::Contact.mock_method_calls[:save].last[:attributes]
    assert_equal '3125551212', attributes['mobile_phone']
    assert_equal 'bill.johnson@domain.com', attributes['email_address']
    assert_equal 'bill', attributes['first_name']
    assert_equal 'johnson', attributes['last_name']
    assert_equal '60606', attributes['zip_code']
  end

  should "be able to save a contact with little info" do
    contact = SignalApi::Contact.new('mobile_phone' => '3125551212', 'email_address' => 'bill.johnson@domain.com')
    contact.save

    attributes = SignalApi::Contact.mock_method_calls[:save].last[:attributes]
    assert_equal '3125551212', attributes['mobile_phone']
    assert_equal 'bill.johnson@domain.com', attributes['email_address']
  end

  should "should throw exceptions no parms" do
    contact = SignalApi::Contact.new()

    assert_raise SignalApi::InvalidParameterException do
      contact.send(:validate_contact_update)
    end
  end

  should "should throw exceptions one parm not mobile_phone" do
    contact = SignalApi::Contact.new('first_name' => 'bill')

    assert_raise SignalApi::InvalidParameterException do
      contact.send(:validate_contact_update)
    end
  end

  should "should throw exceptions one parm mobile_phone" do
    contact = SignalApi::Contact.new('mobile_phone' => '3125551212')

    assert_raise SignalApi::InvalidParameterException do
      contact.send(:validate_contact_update)
    end
  end

  should "should throw exceptions two parms no mobile_phone" do
    contact = SignalApi::Contact.new('first_name' => 'bill', 'last_name' => 'johnson')

    assert_raise SignalApi::InvalidParameterException do
      contact.send(:validate_contact_update)
    end
  end

end
