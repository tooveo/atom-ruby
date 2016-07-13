require_relative 'helper'
require 'atom_ruby/back_off'
class BackOffTest
  def self.test_back_off
    backoff=BackOff.new
    # while true
    #   time = backoff.retry_time
    #   puts time
    #   sleep time
    # end

  end
  test_back_off
end