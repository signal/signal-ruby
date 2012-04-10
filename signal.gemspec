# -*- encoding: utf-8 -*-
require File.expand_path('../lib/signal/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Wood"]
  gem.email         = ["john@signalhq.com"]
  gem.description   = %q{TODO: Ruby implementation of the Signal API}
  gem.summary       = %q{TODO: Ruby implementation of the Signal API}
  gem.homepage      = "http://dev.signalhq.com"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "signal"
  gem.require_paths = ["lib"]
  gem.version       = Signal::VERSION
end
