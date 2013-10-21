require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'

YARD::Rake::YardocTask.new do |t|
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test
