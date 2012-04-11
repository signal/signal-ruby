# SignalApi

Ruby implementation of the Signal API. API details can be found at [http://dev.signalhq.com](http://dev.signalhq.com)

## Installation

Add this line to your application's Gemfile:

    gem 'signal_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signal_api

## Usage

Before using any of the APIs, you will need to set your API key:

    SignalApi.api_key = 'foobar123456abcxyz77'

You may also specify where SignalApi should log messages (optional):

    SignalApi.logger = Rails.logger
    SignalApi.logger = Logger.new(STDERR)

After SignalApi has been configured, you may use any of the API classes to interact with the Signal platform.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
