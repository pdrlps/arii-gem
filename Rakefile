#!/usr/bin/env rake
require "bundler/gem_tasks"
 
require 'rake/testtask'
 
Rake::TestTask.new do |t|
  t.libs << 'lib/i2x'
  t.test_files = FileList['test/lib/i2x/*_test.rb']
  t.verbose = true
end
 
task :default => :test