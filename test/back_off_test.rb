require 'atom_ruby/back_off'
require_relative 'helper'
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