module SignalApi

  # The type of subscription
  class SubscriptionType
    SMS = "SMS"
    EMAIL = "EMAIL"
  end

  # Manage subscriptions to, and send messages to subscribers of a List.
  class List < SignalHttpApi

    # Create a new List object
    #
    # @param [Fixnum] list_id The ID of the list in the Signal platform
    def initialize(list_id)
      @list_id = list_id
      raise InvalidParameterException.new("list_id cannot be nil") if @list_id.nil?
    end

    # Create a new subscription to the list.
    #
    # @param [SubscriptionType] subscription_type The type of subscription to create
    # @param [Contact] contact The contact to create the subscription for.  The contact must contain a valid
    #                          mobile phone number for SMS subscriptions, and a valid email address for
    #                          EMAIL subscriptions.  Any other attributes stored with the contact will also
    #                          be stored on the Signal platform.
    # @param [Hash] options <b>Optional</b> The options used to create the subscription
    # @option options [String] :source_keyword The source keyword to use when creating the subscription (for SMS subscriptions)
    def create_subscription(subscription_type, contact, options={})
      validate_create_subscription_request(subscription_type, contact, options)

      builder = Builder::XmlMarkup.new
      body = builder.subscription do |subscription|
        subscription.tag!('subscription-type', subscription_type)
        subscription.tag!('source-keyword', options[:source_keyword]) if options[:source_keyword]
        subscription.user do |user|
          contact.attributes.each do |attribute_name, attribute_value|
            user.__send__(attribute_name, attribute_value)
          end
        end
      end

      SignalApi.logger.info "Attempting to create a subscription to list #{@list_id}"
      SignalApi.logger.debug "Subscription data: #{body}"
      response = self.class.with_retries do
        self.class.post("/api/subscription_campaigns/#{@list_id}/subscriptions.xml",
                        :body => body,
                        :format => :xml,
                        :headers => self.class.common_headers)
      end

      if response.code != 200
        self.class.handle_api_failure(response)
      end
    end


    # destroy a subscription existing on the list
    #
    # @param [SubscriptionType] subscription_type The type of subscription to destroy
    # @param [Contact] contact The contact to destroy the subscription for.  The contact must contain a valid
    #                          mobile phone number for SMS subscriptions, and a valid email address for
    #                          EMAIL subscriptions.  
    def destroy_subscription(subscription_type, contact)
      validate_destroy_subscription_request(subscription_type, contact)

      SignalApi.logger.info "Attempting to destroy a subscription to list #{@list_id}"
      SignalApi.logger.debug "Contact data: #{contact.inspect}"
      
      if subscription_type == SubscriptionType::SMS
        contact_id = contact.mobile_phone
      else
        contact_id = contact.email_address
      end

      response = self.class.with_retries do
        self.class.delete("/api/subscription_campaigns/#{@list_id}/#{contact_id}.xml",
                        :headers => self.class.common_headers)
      end

      if response.code != 200
        self.class.handle_api_failure(response)
      end
    end

    private

    def validate_create_subscription_request(subscription_type, contact, options)
      unless [SubscriptionType::SMS, SubscriptionType::EMAIL].include?(subscription_type)
        raise InvalidParameterException.new("Invalid subscription type")
      end

      if contact.nil?
        raise InvalidParameterException.new("A contact must be provided")
      end

      if subscription_type == SubscriptionType::SMS && !Phone.valid?(contact.mobile_phone)
        raise InvalidParameterException.new("A valid mobile phone number required for SMS subscriptions")
      end

      if subscription_type == SubscriptionType::EMAIL && !EmailAddress.valid?(contact.email_address)
        raise InvalidParameterException.new("A valid email address required for EMAIL subscriptions")
      end
    end

    def validate_destroy_subscription_request(subscription_type, contact)
      unless [SubscriptionType::SMS, SubscriptionType::EMAIL].include?(subscription_type)
        raise InvalidParameterException.new("Invalid subscription type")
      end

      if contact.nil?
        raise InvalidParameterException.new("A contact must be provided")
      end

      if subscription_type == SubscriptionType::SMS && !Phone.valid?(contact.mobile_phone)
        raise InvalidParameterException.new("A valid mobile phone number required for SMS subscriptions")
      end

      if subscription_type == SubscriptionType::EMAIL && !EmailAddress.valid?(contact.email_address)
        raise InvalidParameterException.new("A valid email address required for EMAIL subscriptions")
      end
    end

  end
end

