# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pulse-meter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ilya Averyanov"]
  gem.email         = ["av@fun-box.ru"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pulse-meter"
  gem.require_paths = ["lib"]
  gem.version       = PulseMeter::VERSION

  gem.add_runtime_dependency('redis')

  gem.add_development_dependency('mock_redis')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
end
