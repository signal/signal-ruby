require 'test_helper'

class ListTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false

    @list = SignalApi::List.new(1)
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
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.create_subscription("foo", SignalApi::Contact.new)
    end
    assert_equal "Invalid subscription type", exception.message
  end

  should "raise an error if calling create_subscription and no contact was provided" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.create_subscription(SignalApi::SubscriptionType::SMS, nil)
    end
    assert_equal "A contact must be provided", exception.message
  end

  should "not be able to create a SMS subscription without a mobile phone number" do
    exception = assert_raise SignalApi::InvalidMobilePhoneException do
      @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to create a SMS subscription with an invalid mobile phone number" do
    exception = assert_raise SignalApi::InvalidMobilePhoneException do
      @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '1234', 'first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to create an email subscription without an email address" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.create_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "not be able to create an email subscription with an invalid email address" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.create_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('email-address' => 'foo', 'first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "be able to create a new subscription" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['200', 'Success'])
    @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
  end

  should "returns false if the subscription could not be created" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/subscriptions.xml</request>
  <message>You are already signed up to the TEST mobile subscription list. To opt-out, send the text message 'STOP TEST' to 839863.</message>
</error>
END
    assert_equal false, @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
  end

  should "returns false if the subscription could not be created because of recent unsubscribe" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/subscriptions.xml</request>
  <message>Subscriber cannot be re-added since they have unsubscribed within the past 30 days</message>
</error>
END
    assert_equal false, @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
  end

  should "returns false if the subscription already exists but was unconfirmed" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/subscriptions.xml</request>
  <message>User already subscribed, resending confirmation message: to confirm reply y</message>
</error>
END
    assert_equal false, @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
  end

  should "raise an exception if the subscription could not be created due to invalid mobile" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/subscriptions.xml</request>
  <message>Could not find the carrier for mobile phone 3125551212</message>
</error>
END
    assert_raise SignalApi::InvalidMobilePhoneException do
      @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'), :source_keyword => 'FOO')
    end
  end

  #
  # destroy_subscription
  #
  should "raise an error if trying to destroy a subscription with an invalid subscription type" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.destroy_subscription("foo", SignalApi::Contact.new)
    end
    assert_equal "Invalid subscription type", exception.message
  end

  should "raise an error if calling destroy_subscription andno contact was provided" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.destroy_subscription(SignalApi::SubscriptionType::SMS, nil)
    end
    assert_equal "A contact must be provided", exception.message
  end

  should "not be able to destroy an SMS subscription without a mobile phone number" do
    exception = assert_raise SignalApi::InvalidMobilePhoneException do
      @list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to destroy an SMS subscription with an invalid mobile phone number" do
    exception = assert_raise SignalApi::InvalidMobilePhoneException do
      @list.create_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '1234', 'first-name' => 'John'))
    end
    assert_equal "A valid mobile phone number required for SMS subscriptions", exception.message
  end

  should "not be able to destroy an email subscription without an email address" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.destroy_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "not be able to destroy an email subscription with an invalid email address" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.destroy_subscription(SignalApi::SubscriptionType::EMAIL, SignalApi::Contact.new('email-address' => 'foo', 'first-name' => 'John'))
    end
    assert_equal "A valid email address required for EMAIL subscriptions", exception.message
  end

  should "be able to destroy a subscription" do
    FakeWeb.register_uri(:delete, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions/3125551212.xml', :status => ['200', 'Success'])
    @list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'))
  end

  should "return false if the subscription could not be destroyed" do
    FakeWeb.register_uri(:delete, SignalApi.base_uri + '/api/subscription_campaigns/1/subscriptions/3125551212.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/3125551212.xml</request>
  <message>3125551212 is not subscribed to campaign ID 1</message>
</error>
END
    assert_equal false, @list.destroy_subscription(SignalApi::SubscriptionType::SMS, SignalApi::Contact.new('mobile-phone' => '3125551212', 'first-name' => 'John'))
  end

  #
  # send_message
  #
  should "raise an error if trying to send a mesasge without a description" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.send_message(nil, "This is the message")
    end
    assert_equal "A description must be provided", exception.message
  end

  should "raise an error if trying to send a mesasge without a message" do
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.send_message("This is the description", "")
    end
    assert_equal "A text message must be provided", exception.message
  end

  should "raise an error if trying to send a mesasge greater than 160 characters" do
    message = 161.times.inject("") { |msg, i| msg << "a" }
    exception = assert_raise SignalApi::InvalidParameterException do
      @list.send_message("This is the description", message)
    end
    assert_equal "The text message must not be greater than 160 characters", exception.message
  end

  should "be able to send a message to a subscription list" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/send_message.xml', :status => ['200', 'Success'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<scheduled-message>
  <id type="integer">101</id>
</scheduled-message>
END
    message_id = @list.send_message("Some description", "A message", :send_at => Time.local(2012, 4, 17, 10, 05, 07), :segment_id => 7, :tags => [1, 2],
                                    :carrier_overrides => [SignalApi::CarrierOverrideMessage.new(2, "some override message")])
    assert_equal 101, message_id
  end

  should "raise an exception if unable to send the message successfully" do
    FakeWeb.register_uri(:post, SignalApi.base_uri + '/api/subscription_campaigns/1/send_message.xml', :status => ['422', 'Bad Request'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>/api/subscription_campaigns/1/send_message.xml</request>
  <message>No segment could be found with an id of 404</message>
</error>
END
    assert_raise SignalApi::ApiException do
      @list.send_message("Some description", "A message", :send_at => Time.local(2012, 4, 17, 10, 05, 07), :segment_id => 404,
                         :carrier_overrides => [SignalApi::CarrierOverrideMessage.new(2, "some override message")])
    end
  end

end
