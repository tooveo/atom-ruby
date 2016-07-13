require "bundler/gem_tasks"
require 'rake/testtask'
require 'coveralls/rake/task'
task :default => :spec

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
end
