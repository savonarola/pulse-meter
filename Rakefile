#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'coffee-script'
require 'listen'
require 'rspec/core/rake_task'
require 'sprockets'
require 'yard'
require 'yard/rake/yardoc_task'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard)

ROOT = File.dirname(__FILE__)

task :default => :spec

namespace :coffee do
  COFFEE_PATH = "#{ROOT}/lib/pulse-meter/visualize/public/coffee"

  def compile_js
    env = Sprockets::Environment.new
    env.append_path COFFEE_PATH
    data = env['application.coffee']
    open("#{ROOT}/lib/pulse-meter/visualize/public/js/application.js", "w").write(data)
    puts "application.js compiled"
  end

  desc "Compile coffee to js"
  task :compile do
    compile_js
  end

  desc "Watch coffee files and recomplile them immediately"
  task :watch do
    Listen.to(COFFEE_PATH) do |modified, added, removed|
      puts "Modified: #{modified}" unless modified.empty?
      puts "Added: #{added}" unless added.empty?
      puts "Removed: #{removed}" unless removed.empty?
      puts "Recompiling..."
      compile_js
    end
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
