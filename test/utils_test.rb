require 'test/unit'
require_relative 'helper'
require 'atom_ruby/utils'
class UtilsTest < Test::Unit::TestCase
  def test_auth
    assert_equal("905d00456557d8b77faefb1518f3210eddae94ce716a6ddf96109e182cdd66c0", Utils.auth('12aa12s2', 'message'))
  end
end