require 'rubygems'
require 'bundler'
require 'fileutils'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'fakeweb'
require 'shoulda'
require 'mocha'

require 'signal_api'

FileUtils.mkdir_p("log")
SignalApi.logger = Logger.new("log/test.log")
