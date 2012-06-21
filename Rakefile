#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require "yard"
require 'yard/rake/yardoc_task'

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard)

ROOT = File.dirname(__FILE__)

task :default => :spec

namespace :coffee do
	desc "Complile coffee to js"
	task :compile do
		system 'coffee', '-c', "#{ROOT}/lib/pulse-meter/visualize/public/"
		puts "Done"
	end

	desc "Watch coffee files and recomplile them immediately"
	task :watch do
		system 'coffee', '--watch', '-c', "#{ROOT}/lib/pulse-meter/visualize/public/"
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
