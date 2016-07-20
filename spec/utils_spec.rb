require_relative 'spec_helper'
require 'atom_ruby/utils'
RSpec.describe 'utils' do

  describe ".auth(key, data)" do
    it 'can do sha256 HMAC of data with given key' do
      raise unless "905d00456557d8b77faefb1518f3210eddae94ce716a6ddf96109e182cdd66c0" == IronSourceAtom::Utils.auth('12aa12s2', 'message')
    end
  end
end
