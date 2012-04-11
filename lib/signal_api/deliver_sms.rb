module SignalApi

  # Deliver a SMS message using Signal's messaging API
  class DeliverSms < SignalHttpApi

    base_uri "https://api.imws.us"

    # Create an instance of this class, with your messaging API credentials.
    # These credentials are separate from the api_key that is used by the
    # other APIs, and can be found in the API campaign configuration.
    def initialize(username, password)
      @username = username
      @password = password

      if @username.nil? || @password.nil?
        raise InvalidParameterException.new("username and password must be provided")
      end
    end

    # Deliver a SMS message to a mobile phone.  Messages exceeding the 160 character
    # limit will be split into multiple messages.
    #
    # @param [String] mobile_phone The mobile phone to send the message to
    # @param [String] message The message to send
    #
    # @return [String] The unique message ID
    def deliver(mobile_phone, message)
      sanitized_mobile_phone = Phone.sanitize(mobile_phone)
      unless Phone.valid?(sanitized_mobile_phone)
        raise InvalidParameterException.new("An invalid mobile phone was specified: #{mobile_phone}")
      end

      if message.nil? || message.strip.empty?
        raise InvalidParameterException.new("A message must be provided")
      end

      SignalApi.logger.info "Delivering the following message to #{sanitized_mobile_phone}: #{message}"
      response = self.class.post('/messages/send',
                                 :basic_auth => { :username => @username, :password => @password },
                                 :query => { :mobile_phone => sanitized_mobile_phone, :message => message })

      if response.code == 200
        response.parsed_response =~ /^Message ID: (.*)$/
        $1 
      else
        handle_api_failure(response)
      end
    end
  end

end

