require_relative 'spec_helper'
require 'atom_ruby/back_off'

RSpec.describe 'back_off' do

  describe '.retry_time' do
    it 'gives retry time' do
      time = IronSourceAtom::BackOff.new(0.5, 30).retry_time
      expect(time).to be_within(0.5).of(1)
    end

    it 'gives max retry time' do
      backoff=IronSourceAtom::BackOff.new(5, 30)
      100.times{backoff.retry_time}
      time = backoff.retry_time
      expect(time).to be_within(15).of(30)
    end

  end

end