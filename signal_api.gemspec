# -*- encoding: utf-8 -*-
require File.expand_path('../lib/signal_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Wood"]
  gem.email         = ["john@signalhq.com"]
  gem.description   = %q{Ruby implementation of the Signal API}
  gem.summary       = %q{Ruby implementation of the Signal API}
  gem.homepage      = "http://dev.signalhq.com"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "signal_api"
  gem.require_paths = ["lib"]
  gem.version       = SignalApi::VERSION

  gem.add_dependency('httparty', '~> 0.8.1')

  gem.add_development_dependency('fakeweb', '~> 1.3.0')
  gem.add_development_dependency('shoulda', '~> 3.0.1')
  gem.add_development_dependency('rake', '~> 0.9.2.2')
  gem.add_development_dependency('yard', '~> 0.7.5')
  gem.add_development_dependency('bluecloth', '~> 2.2.0')
end
