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
      raise InvalidParameterException.new("mobile_phone cannot be blank") if mobile_phone.blank?

      SignalApi.logger.info "Attempting to lookup carrier for mobile phone #{mobile_phone}"

      with_retries do
        response = get("/app/carriers/lookup/#{mobile_phone}.xml",
                       :format => :xml,
                       :headers => common_headers)

        if response.code == 200 && response.parsed_response['carrier']
          Carrier.new(response.parsed_response['carrier']['id'], response.parsed_response['carrier']['name'])
        elsif response.code == 404
          raise InvalidMobilePhoneException.new("carrier for mobile phone #{mobile_phone} could not be found") 
        else
          handle_api_failure(response)
        end
      end
    end

  end
end
