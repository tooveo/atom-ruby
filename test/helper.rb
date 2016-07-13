require 'coveralls'
Coveralls.wear!

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'test'
  add_filter 'example'
  add_filter 'lib/iron_source_atom_tracker.rb'
  add_filter 'lib/atom_ruby/event_task_pool.rb'
end
require 'iron_source_atom'
require 'iron_source_atom_tracker'
class Helper
end