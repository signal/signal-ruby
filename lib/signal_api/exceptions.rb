module SignalApi
  # Exception raised when a request to the Signal API fails
  class ApiException < StandardError; end

  # Exception raised when the api key is not properly set
  class InvalidApiKeyException < StandardError; end
end
