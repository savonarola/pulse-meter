# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Ilya Averyanov", "Sergey Averyanov"]
  gem.email         = ["av@fun-box.ru", "averyanov@gmail.com"]
  gem.description   = %q{Lightweight metrics processor}
  gem.summary       = %q{
    Lightweight Redis-based metrics aggregator and processor
    with CLI and simple and customizable WEB interfaces
  }
  gem.homepage      = "https://github.com/savonarola/pulse-meter"

  gem.required_ruby_version = '>= 1.9.2'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pulse-meter"
  gem.require_paths = ["lib"]
  gem.version       = "0.4.10"

  gem.add_runtime_dependency('pulse-meter-cli')
  gem.add_runtime_dependency('pulse-meter-visualizer')

  gem.add_development_dependency('rake')
  gem.add_development_dependency('foreman')
end
