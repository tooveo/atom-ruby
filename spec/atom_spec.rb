require_relative 'spec_helper'
require 'iron_source_atom'

RSpec.describe 'atom' do

  def atom
    IronSourceAtom::Atom.new("SomeString", "SomeString")
  end

  describe "initialise" do
    it "raises ArgumentError if param auth is nil" do
      expect{ IronSourceAtom::Atom.new(nil) }.to raise_error ArgumentError
    end
  end

describe ".put_event(stream, data)" do
  it "raises ArgumentError if param stream is nil" do
    expect{ atom.put_event(nil, "AnotherString") }.to raise_error ArgumentError
  end

  it "raises ArgumentError if param stream is ''" do
    expect{ atom.put_event('', "AnotherString") }.to raise_error ArgumentError
  end

  it "raises ArgumentError if param data is nil" do
    expect{ atom.put_event('SomeString', nil) }.to raise_error ArgumentError
  end

  it "raises ArgumentError if param data is ''" do
    expect{ atom.put_event('SomeString', '') }.to raise_error ArgumentError
  end

  it "return response with code 400 if stream is invalid" do
    expect{ atom.put_event("SomeString", "AnotherString").code ==400}
  end

end

  describe ".put_events(stream, data)" do
    it "raises ArgumentError if param stream is nil" do
      expect{ atom.put_events(nil, "AnotherString") }.to raise_error ArgumentError
    end

    it "raises ArgumentError if param stream is ''" do
      expect{ atom.put_events('', "AnotherString") }.to raise_error ArgumentError
    end

    it "raises ArgumentError if param data is nil" do
      expect{ atom.put_events('SomeString', nil) }.to raise_error ArgumentError
    end

    it "raises ArgumentError if param data is ''" do
      expect{ atom.put_events('SomeString', '') }.to raise_error ArgumentError
    end

    it "raises ArgumentError if param data is not valid JSON of Array" do
      expect{ atom.put_events('SomeString', 'SomeString') }.to raise_error ArgumentError
    end

  end

end