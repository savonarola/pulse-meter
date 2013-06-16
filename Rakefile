#!/usr/bin/env rake
require 'bundler/gem_tasks'

task :default => :build

ROOT = File.dirname(__FILE__)

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
