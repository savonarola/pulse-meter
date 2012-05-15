#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :coffee do
	desc "Complile coffee to js"
	task :compile do
		system 'coffee', '-c', 'lib/pulse-meter/visualize/public/'
		puts "Done"
	end

	desc "Watch coffee files and recomplile them immediately"
	task :watch do
		system 'coffee', '--watch', '-c', 'lib/pulse-meter/visualize/public/'
	end

end

