#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'coffee-script'
require 'rspec/core/rake_task'
require 'sprockets'
require 'yard'
require 'yard/rake/yardoc_task'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard)

ROOT = File.dirname(__FILE__)

task :default => :spec

namespace :assets do
  desc "Compile assests"
  task :compile do
    env = Sprockets::Environment.new
    env.append_path "#{ROOT}/lib/pulse-meter/visualize/public/coffee"
    data = env['application.coffee']
    open("#{ROOT}/lib/pulse-meter/visualize/public/js/application.js", "w").write(data)
    puts "application.js compiled"
  end
end

namespace :yard do
  desc "Open doc index in a browser"
  task :open do
    system 'open', "#{ROOT}/doc/index.html"
  end
end

namespace :example do
  desc "Run minimal example"
  task :minimal do
    chdir(ROOT) do
      system "bundle"
      system "cd examples/minimal && bundle exec foreman start"
    end
  end

  desc "Run full example"
  task :full do
    chdir(ROOT) do
      system "bundle"
      system "cd examples/full && bundle exec foreman start"
    end
  end

end
