require_relative 'helper'
require 'test/unit'
require 'iron_source_atom'
class AtomTest < Test::Unit::TestCase
  def test_new_atom_nil_auth
    assert_raise( ArgumentError ) { IronSourceAtom::Atom.new(nil) }
  end

  def test_put_event_nil_stream
    assert_raise( ArgumentError ) { IronSourceAtom::Atom.new("SomeString", "SomeString").put_event(nil, "AnotherString") }
  end

  def test_put_event_empty_stream
    assert_raise( ArgumentError ) { IronSourceAtom::Atom.new("SomeString", "SomeString").put_event('', "AnotherString") }
  end

  def test_put_events_nil_stream
    assert_raise( ArgumentError ) { IronSourceAtom::Atom.new("SomeString", "SomeString").put_events(nil, "AnotherString") }
  end

  def test_put_events_empty_stream
    assert_raise( ArgumentError ) { IronSourceAtom::Atom.new("SomeString", "SomeString").put_events('', "AnotherString") }
  end

  def test_put_event
    assert_equal(400, IronSourceAtom::Atom.new("SomeString", "SomeString").put_event("SomeString", "AnotherString").code )
  end

  def test_put_events
    assert_equal(400, IronSourceAtom::Atom.new("SomeString", "SomeString").put_events('"SomeString"', '[{"id":11,"message":"first_array_data"},{"id":12,"message":"second_array_data"},{"id":13,"message":"third_array_data"}]').code )
  end

  def test_put_events_no_array
    assert_raise( ArgumentError ){ IronSourceAtom::Atom.new("SomeString", "SomeString").put_events("SomeString", "AnotherString") }
  end


end