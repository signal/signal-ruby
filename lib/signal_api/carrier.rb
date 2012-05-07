module SignalApi

  # Managed carrier from signal api
  class Carrier < SignalHttpApi

    # The Carrier id from Signal
    attr_reader :id

    # The Carrier name from Signal
    attr_reader :name

    def initialize(id, name)
      @id = id
      @name = name
    end

    # Lookup a carrier on textme
    #
    # @param [String] mobile_phone The mobile phone to lookup 
    #
    # @return [carrier] A Carrier object representing the Carrier on the Signal platform
    def self.lookup(mobile_phone)
      SignalApi.logger.info "Attempting to lookup carrier for mobile phone #{mobile_phone}"

      if mobile_phone.blank?
        raise InvalidParameterException.new("mobile_phone cannot be blank")
      end

      response = with_retries do
        get("/app/carriers/lookup/#{mobile_phone}.xml",
             :format => :xml,
             :headers => common_headers)
      end

      if response.code == 200 && response.parsed_response['carrier']
        Carrier.new(response.parsed_response['carrier']['id'], response.parsed_response['carrier']['name'])
      else
        handle_api_failure(response)
      end
    end

  end

end
