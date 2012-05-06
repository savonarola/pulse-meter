# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pulse-meter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ilya Averyanov", "Sergey Averyanov"]
  gem.email         = ["av@fun-box.ru", "averyanov@gmail.com"]
  gem.description   = %q{Lightweight metrics processor}
  gem.summary       = %q{Lightweight metrics processor}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pulse-meter"
  gem.require_paths = ["lib"]
  gem.version       = PulseMeter::VERSION

  gem.add_runtime_dependency('redis')
  gem.add_runtime_dependency('thor')
  gem.add_runtime_dependency('terminal-table')
  gem.add_runtime_dependency('eventmachine')
  gem.add_runtime_dependency('activesupport')

  gem.add_development_dependency('mock_redis')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('timecop')
end
