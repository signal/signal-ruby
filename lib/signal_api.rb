require "httparty"

require "signal_api/version"
require "signal_api/exceptions"
require "signal_api/signal_http_api"

require "signal_api/short_url"

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
      @api_key
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
  end

end
