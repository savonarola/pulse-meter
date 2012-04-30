#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Complile coffee to js"
task :coffee do
	FileList['lib/pulse-meter/visualize/public/js/*.coffee'].each do |f|
		puts "Compiling #{f}..."
		system 'coffee', '-c', f
	end
	puts "Done"
end

