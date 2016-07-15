# ironSource.atom SDK for Ruby
[![License][license-image]][license-url]
[![Build status][travis-image]][travis-url]
[![Coverage Status][coveralls-image]][coveralls-url]

Atom-Ruby is the official ironSource.atom SDK for the Ruby programming language.

- [Signup](https://atom.ironsrc.com/#/signup)

## Installation
```gem
$ gem install iron_source_atom-1.0.0.gem
```

The SDK is divided into 2 separate services:

1. High level Tracker - contains in-memory storage and tracks events based on certain parameters.
2. Low level - contains 2 methods: putEvent() and putEvents() to send 1 event or a batch respectively.

### Tracker usage

```ruby
require 'thread'
require 'json'
require 'iron_source_atom'
class TestTracker
def self.test_multitread
    url = "http://track.atom-data.io/"
    atom_tracker = IronSourceAtom::Tracker.new
    atom_tracker.auth = ""
    a=0
    run_example = true
    (0..5).each do |int|
      Thread.new do
        begin
          while run_example
            data = {
                id: a += 1,
                message: "#{int}Thread_array_data"
            }.to_json
            atom_tracker.track(data, "ibtest")
            puts "send data #{data}"
            sleep(0.05)
            if a > 100
              run_example = false
            end
          end
        end
      end
    end
    sleep 30
  end
  test_multitread
end
`
```

The Tracker process:

You can use track() method in order to track the events to an Atom Stream.
The tracker accumulates events and flushes them when it meets one of the following conditions:
 
1. Flush Interval is reached (default: 10 seconds).
2. Bulk Length is reached (default: 4 events).
3. Maximum Bulk size is reached (default: 64kB).

In case of failure the tracker will preform an exponential backoff with jitter.
The tracker stores events in a memory storage based on Queue.

### Using low level API methods

```ruby
require 'json'
require 'iron_source_atom'

class TestExample
  def self.do_test_job
    url = "http://track.atom-data.io/"
    auth = ""
    atom = IronSourceAtom::Atom.new(auth)

    data_string = {
        id: 1,
        message: "hello_from_ruby"
    }.to_json

    response = atom.put_event("ibtest", data_string)
    puts "Response #{response.code} #{response.message}:
          #{response.body}"

    data1 = {
        id: 11,
        message: "first_array_data"
    }
    data2 = {
        id: 12,
        message: "second_array_data"
    }
    data3 = {
        id: 13,
        message: "third_array_data"
    }

    array_data_string = [data1, data2, data3].to_json

    response = atom.put_events("ibtest", array_data_string)
    puts "Response #{response.code} #{response.message}:
          #{response.body}"

  end

  do_test_job

end
```

### Example

You can use our [example][example-url] for sending data to Atom:

![alt text][example]

[example-url]: https://github.com/ironSource/atom-ruby/tree/feature/ISA-359/example
[example]: https://cloud.githubusercontent.com/assets/7361100/16713929/212a5496-46be-11e6-9ff7-0f5ed2c29844.png "example"
[license-image]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-url]: LICENSE.txt
[travis-image]: https://travis-ci.org/ironSource/atom-ruby.svg?branch=feature%2FISA-359
[travis-url]: https://travis-ci.org/ironSource/atom-ruby
[coveralls-image]: https://coveralls.io/repos/github/ironSource/atom-ruby/badge.svg?branch=feature%2FISA-359
[coveralls-url]: https://coveralls.io/github/ironSource/atom-ruby?branch=feature%2FISA-359