# Signal

A simple library for working with the Signal API (see [http://dev.signalhq.com](http://dev.signalhq.com))

[![Build Status](https://secure.travis-ci.org/signal/signal-ruby.png?branch=master)](http://travis-ci.org/signal/signal-ruby)

Installation
------------

### RubyGems ###
Signal can be installed using RubyGems

    gem install signal_api

Inside your script, be sure to

    require "rubygems"
    require "signal_api"

### Bundler ###
If you're using Bundler, add the following to your Gemfile

    gem "signal_api"

and then run

    bundle install

Usage
------------

Before using, you'll need to set your API key (available within your user account via http://app.signalhq.com):

    SignalApi.api_key = 'foobar123456abcxyz77'

You may also specify where Signal should log messages (optional):

    SignalApi.logger = Rails.logger
    SignalApi.logger = Logger.new(STDERR)

After Signal has been configured, you may use any of the API classes to interact with the Signal platform.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
