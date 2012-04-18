require 'test_helper'

class ListTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  should "not be able to create a List with a nil list id" do
    assert_raise SignalApi::InvalidParameterException do
      SignalApi::List.new(nil)
    end
  end

  #
  # create_subscription
  #
  should "raise an error if trying to create a subscription with an invalid subscription type" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription("foo", SignalApi::Contact.new)
    end
    assert_equal "Invalid subscription type", exception.message
  end

  should "raise an error if no contact was provided" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription(SignalApi::SubscriptionType::SMS, nil)
    end
    assert_equal "A contact must be provided", exception.message
  end

  should "not be able to create a SMS subscription without a mobile phone number" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to create a SMS subscription with an invalid mobile phone number" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '1234', 'first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to create an email subscription without an email address" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "not be able to create an email subscription with an invalid email address" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('email-address' => 'foo', 'first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "be able to create a new subscription" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['200', 'Success'])
    list = SignalApi::List.new(1)
    list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
  end

  should "raise an exception if the subscription could not be created" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/subscriptions.xml</request>
  <message>You are already signed up to the TEST mobile subscription list. To opt-out, send the text message 'STOP TEST' to 839863.</message>
</error>
END
    list = SignalApi::List.new(1)
    assert_raise SignalApi::ApiException do
      list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
    end
  end

  #
  # destroy_subscription
  #
  should "raise an error if trying to destroy a subscription with an invalid subscription type" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.destroy_subscription("foo", SignalApi::Contact.new)
    end
    assert_equal "Invalid subscription type", exception.message
  end

  should "raise an error if no contact was provided" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.destroy_subscription(SignalApi::SubscriptionType::SMS, nil)
    end
    assert_equal "A contact must be provided", exception.message
  end

  should "not be able to destroy an SMS subscription without a mobile phone number" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to destroy an SMS subscription with an invalid mobile phone number" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '1234', 'first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to destroy an email subscription without an email address" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.destroy_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "not be able to destroy an email subscription with an invalid email address" do
    list = SignalApi::List.new(1)
    exception = assert_raise SignalApi::InvalidParameterException do
      list.destroy_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('email-address' => 'foo', 'first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "be able to destroy a subscription" do
    FakeWeb.register_uri(:delete, SignalApi.base_uri + '/api/subscription_campaigns/1/3125551212.xml', :status => ['200', 'Success'])
    list = SignalApi::List.new(1)
    list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'))
  end

  should "raise an exception if the subscription could not be destroyed" do
    FakeWeb.register_uri(:delete, SignalApi.base_uri + '/api/subscription_campaigns/1/3125551212.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/3125551212.xml</request>
  <message>3125551212 is not subscribed to campaign ID 1</message>
</error>
END
    list = SignalApi::List.new(1)
    assert_raise SignalApi::ApiException do
      list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'))
    end
  end


end
