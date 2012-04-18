#!/usr/bin/env rake
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rake/testtask'
require 'yard'

task :default => :test

namespace :test do
  Rake::TestTask.new(:api) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = ENV['TEST'] || "test/api/**/*_test.rb"
    test.verbose = true
  end

  Rake::TestTask.new(:mocks) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = ENV['TEST'] || "test/mocks/**/*_test.rb"
    test.verbose = true
  end
end

desc 'Run all of the tests'
task :test => ["test:api", "test:mocks"]

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end

desc 'Delete yard, and other generated files'
task :clobber => [:clobber_yard]

desc 'Delete yard generated files'
task :clobber_yard do
  puts 'rm -rf doc .yardoc'
  FileUtils.rm_rf ['doc', '.yardoc']
end

