require 'test/unit'
require_relative 'helper'
require 'iron_source_atom'
require 'iron_source_atom_tracker'
class AtomTest < Test::Unit::TestCase
  def test_new_atom_nil_auth
    assert_raise( ArgumentError ) { IronSourceAtom.new(nil) }
  end

  def test_put_event_nil_stream
    assert_raise( ArgumentError ) { IronSourceAtom.new("SomeString", "SomeString").put_event(nil, "AnotherString") }
  end

  def test_put_event_empty_stream
    assert_raise( ArgumentError ) { IronSourceAtom.new("SomeString", "SomeString").put_event('', "AnotherString") }
  end

  def test_put_events_nil_stream
    assert_raise( ArgumentError ) { IronSourceAtom.new("SomeString", "SomeString").put_event(nil, "AnotherString") }
  end

  def test_put_events_empty_stream
    assert_raise( ArgumentError ) { IronSourceAtom.new("SomeString", "SomeString").put_event('', "AnotherString") }
  end

end