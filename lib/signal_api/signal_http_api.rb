module SignalApi
  class SignalHttpApi
    BASE_URI = "https://app.signalhq.com"

    include HTTParty
    base_uri BASE_URI
    default_timeout 15

    protected

    def self.with_retries
      retry_counter = 0

      if SignalApi.retries > 0
        begin
          yield
        rescue Exception => e
          SignalApi.logger.error "Exception: #{e.message}"
          sleep 1
          retry_counter += 1

          if retry_counter < SignalApi.retries
            SignalApi.logger.warn "Re-trying..."
            retry
          else
            SignalApi.logger.error "All retry attempts have failed."
            raise
          end
        end
      else
        yield
      end
    end

    def self.handle_api_failure(response)
      if response.code == 401
        raise AuthFailedException.new("Authentication to the Signal platform failed.  Make sure your API key is correct.")
      else
        message = "API request failed with a response code of #{response.code}.  Respone body: #{response.body}"
        SignalApi.logger.error message
        raise ApiException.new(message)
      end
    end

    def self.common_headers
      { 'Content-Type' => 'application/xml', 'api_token' => SignalApi.api_key }
    end
  end
end
