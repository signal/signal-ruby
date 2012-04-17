require "httparty"
require "builder"
require "logger"

module SignalApi

  # Interact with the Signal platform via its published web API.
  class << self

    # Set your Signal API key.
    #
    # @param [String] api_key Your Signal API key
    #
    # @example
    #   SignalApi.api_key = 'foobar123456abcxyz77'
    def api_key=(api_key)
      @api_key = api_key
    end

    # Get your Signal API key.
    def api_key
      if @api_key.nil? || @api_key.strip == ""
        raise InvalidApiKeyException.new("The api_key is blank or nil.  Use SignalApi.api_key= to set it.")
      else
        @api_key
      end
    end

    # Set the logger to be used by Signal.
    #
    # @param [Logger] logger The logger you would like Signal to use
    #
    # @example
    #   SignalApi.logger = Rails.logger
    #   SignalApi.logger = Logger.new(STDERR)
    def logger=(logger)
      @logger = logger
    end

    # Get the logger used by Signal.
    def logger
      @logger || Logger.new("/dev/null")
    end

    # Set the number of times failed API calls should be retried.  Defaults to 0.
    #
    # @param [Fixnum] retries The number of times API calls should be retried
    #
    # @example
    #   SignalApi.retries = 3
    def retries=(retries)
      @retries = retries
    end

    # Get the number of times failed API calls should be retried.
    def retries
      @retries || 0
    end
  end

    # Set the default timeout for API calls.  Defaults to 15 seconds.
    #
    # @param [Fixnum] timeout The default timeout (in seconds) for API calls
    #
    # @example
    #   SignalApi.timeout = 5
    def timeout=(timeout)
      @timeout = timeout
    end

    # Get the default timeout for API calls.
    def timeout
      @timeout || 15
    end
  end

end

require "signal_api/core_ext/nil_class"
require "signal_api/core_ext/string"
require "signal_api/core_ext/array"
require "signal_api/core_ext/hash"

require "signal_api/util/phone"
require "signal_api/util/email_address"

require "signal_api/contact"
require "signal_api/exceptions"
require "signal_api/signal_http_api"

require "signal_api/deliver_sms"
require "signal_api/list"
require "signal_api/segment"
require "signal_api/short_url"

