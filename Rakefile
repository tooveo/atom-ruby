require "bundler/gem_tasks"
require 'rake/testtask'
task :default => :spec

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
end