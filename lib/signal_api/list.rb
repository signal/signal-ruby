module SignalApi

  # The type of subscription
  class SubscriptionType
    SMS = "SMS"
    EMAIL = "EMAIL"
  end

  # Represents a message to be sent to users on a particular carrier
  class CarrierOverrideMessage
    attr_accessor :carrier_id, :text

    def initialize(carrier_id, text)
      @carrier_id = carrier_id
      @text = text
    end
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

    # Destroy a subscription which exists in this list.
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

    # Sends an SMS message to the subscribers of the subscription list.
    #
    # @param [String] description A description of the message.
    # @param [String] text The message to send.  Must not be greater than 160 characters.
    # @param [Hash] options <b>Optional</b> The options used when sending the message.
    # @option options [Time] :send_at The date and time to send the message. The message will be
    #                                 sent immediately if not provided.
    # @option options [Fixnum] :segment_id The id of the segment to send the message to. If not
    #                                      specified, the message will be sent to all subscribers in the list.
    # @option options [Array<Fixnum>] :tags An array of tag ids to tag the scheduled message with.
    # @option options [Array<CarrierOverrideMessage>] :carrier_overrides An alternate text message to send to
    #                                      users on a particular carrier.
    # @return [Fixnum] The ID of the scheduled message on the Signal platform.
    def send_message(description, text, options={})
      raise InvalidParameterException.new("A description must be provided") if description.blank?
      raise InvalidParameterException.new("A text message must be provided") if text.blank?
      raise InvalidParameterException.new("The text message must not be greater than 160 characters") if text.size > 160

      builder = Builder::XmlMarkup.new
      body = builder.message do |message|
        message.description(description)
        message.text(text)
        message.send_at(options[:send_at].strftime("%Y-%m-%d %H:%M:%S")) if options[:send_at]
        message.segment_id(options[:segment_id]) if options[:segment_id]

        if options[:tags]
          message.tags(:type => :array) do |tags|
            options[:tags].each { |tag_id| tags.tag(tag_id) }
          end
        end

        if options[:carrier_overrides]
          message.carrier_overrides(:type => :array) do |carrier_overrides|
            options[:carrier_overrides].each do |carrier_override_message|
              carrier_overrides.carrier_override do |carrier_override|
                carrier_override.carrier_id(carrier_override_message.carrier_id)
                carrier_override.text(carrier_override_message.text)
              end
            end
          end
        end
      end

      SignalApi.logger.info "Attempting to send a message to list #{@list_id}"
      SignalApi.logger.debug "Message data: #{body}"
      response = self.class.with_retries do
        self.class.post("/api/subscription_campaigns/#{@list_id}/send_message.xml",
                        :body => body,
                        :format => :xml,
                        :headers => self.class.common_headers)
      end

      if response.code == 200
        data = response.parsed_response['scheduled_message']
        data['id']
      else
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

