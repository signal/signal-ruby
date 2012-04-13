module SignalApi

  # The type of subscription
  class SubscriptionType
    SMS = "SMS"
    EMAIL = "EMAIL"
  end

  # Manage subscriptions to, and send messages to subscribers of a List.
  class List < SignalHttpApi

    def initialize(campaign_id)
      @campaign_id = campaign_id
      raise InvalidParameterException.new("campaign_id cannot be nil") if @campaign_id.nil?
    end

    # Create a new subscription to the list.
    #
    # @param [SubscriptionType] subscription_type The type of subscription to create
    # @param [Hash] options The options used to create the subscription
    # @option options [Hash] :user A hash of user data, with attribute names as keys, and attribute values as values.
    #                           Mobile phone must be provided for SMS subscriptions.  Email address must be provided
    #                           for email subscriptions.
    # @option options [String] :source_keyword The source keyword to use when creating the subscription (for SMS subscriptions)
    def create_subscription(subscription_type, options={})
      unless [SubscriptionType::SMS, SubscriptionType::EMAIL].include?(subscription_type)
        raise InvalidParameterException.new("Invalid subscription type")
      end

      if options[:user].nil? || options[:user].empty?
        raise InvalidParameterException.new("User data must be provided")
      end

      if subscription_type == SubscriptionType::SMS && !Phone.valid?(options[:user]['mobile-phone'])
        raise InvalidParameterException.new("A valid mobile phone number required for SMS subscriptions")
      end

      if subscription_type == SubscriptionType::EMAIL && !EmailAddress.valid?(options[:user]['email-address'])
        raise InvalidParameterException.new("A valid email address required for EMAIL subscriptions")
      end

      builder = Builder::XmlMarkup.new
      body = builder.subscription do |subscription|
        subscription.tag!('subscription-type', subscription_type)
        subscription.tag!('source-keyword', options[:source_keyword]) if options[:source_keyword]
        subscription.user do |user|
          options[:user].each do |attribute_name, attribute_value|
            user.__send__(attribute_name, attribute_value)
          end
        end
      end

      SignalApi.logger.info "Attempting to create a subscription to list #{@campaign_id}"
      SignalApi.logger.debug "Subscription data: #{body}"
      response = self.class.post("/api/subscription_campaigns/#{@campaign_id}/subscriptions.xml",
                                 :body => body,
                                 :format => :xml,
                                 :headers => self.class.common_headers)

      if response.code != 200
        self.class.handle_api_failure(response)
      end
    end

  end
end

