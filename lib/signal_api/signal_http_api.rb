module SignalApi
  class SignalHttpApi
    BASE_URI = "https://app.signalhq.com"

    include HTTParty
    base_uri BASE_URI
    default_timeout 5

    protected

    def self.handle_api_failure(response)
      if response.code == 401
        raise AuthFailedException.new("Authentication to the Signal platform failed.  Make sure your API key is correct.")
      else
        message = "API request failed with a response code of #{response.code}.  Respone body: #{response.body}"
        SignalApi.logger.error message
        raise ApiException.new(message)
      end
    end
  end
end
