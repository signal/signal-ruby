module SignalApi
  # Base class for exceptions that should not be retried
  class NonRetryableException < StandardError; end

  # Exception raised when a request to the Signal API fails
  class ApiException < StandardError; end

  # Exception raised when the api key is not properly set
  class InvalidApiKeyException < StandardError; end

  # Authentication to the Signal platform failed.  Make sure your API key is correct.
  class AuthFailedException < StandardError; end

  # An invalid parameter was passed to the given method
  class InvalidParameterException < StandardError; end

  # An invalid mobile phone number was passed
  class InvalidMobilePhoneException < NonRetryableException; end
end
