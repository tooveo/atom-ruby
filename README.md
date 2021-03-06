# ironSource.atom SDK for Ruby

[![License][license-image]][license-url]
[![Docs][docs-image]][docs-url]
[![Build status][travis-image]][travis-url]
[![Coverage Status][coveralls-image]][coveralls-url]
[![Gem Version][gem-image]][gem-url]

atom-ruby is the official [ironSource.atom](http://www.ironsrc.com/data-flow-management) SDK for Ruby.

- [Signup](https://atom.ironsrc.com/#/signup)
- [Documentation][docs-url]
- [Installation](#installation)
- [Usage](#usage)
- [Change Log](#change-log)
- [Example](#example)

## Installation

### Installation using gem
```bash
$ gem install iron_source_atom
```

## Usage

You may use the SDK in two different ways:

1. High level "Tracker" - contains in-memory storage and tracks events based on certain parameters.
2. Low level - contains 2 methods: putEvent() and putEvents() to send 1 event or a batch respectively.

### High Level SDK - "Tracker"

The Tracker is used for sending events to Atom based on several conditions:
 
1. Flush Interval is reached (default: 10 seconds).
2. Bulk Length is reached (default: 50 events).
3. Maximum Bulk byte size is reached (default: 128KB).
  
```ruby
require 'iron_source_atom'

class TestTracker

def self.test_multitread
    url = 'http://track.atom-data.io/'

    error_callback = lambda do |error_str, stream, data|
        print "Error: #{error_str}\n"
        print "Data: #{data}"
        print "Stream: #{stream}"
    end
    
    # Creates a new instance of Atom Tracker.
    # * +url+ Atom tracker endpoint url. Default is http://track.atom-data.io/
    # * +error_callback+ Optional, callback to be called when there is an error at the tracker
    # * +is_blocking+ Optional, should the tracker block, default true.
    atom_tracker = IronSourceAtom::Tracker.new(url, error_callback, is_blocking=false)
    # Change auth key
    atom_tracker.auth = "YOUR_PRE_SHARED_AUTH_KEY"
    # Track to stream
    atom_tracker.track("stream", "data")
    # Force Flush all
    atom_tracker.flush
    # Force Flush one stream
    atom_tracker.flush_with_stream("stream")
    # Enable debug printing:
    atom_tracker.is_debug_mode = true
end
```

In order to change tracker flush conditions:  
```ruby
atom_tracker.bulk_length = 100 # Each bulk(batch) length
atom_tracker.bulk_size_byte = 64*1024 # Each bulk (batch) size in bytes 
atom_tracker.flush_interval = 10 # Flush interval in seconds
```

In case of failure the tracker will preform an exponential backoff with jitter.
The tracker stores events in memory.

### Tracker flow control

**Note:**  
By default the tracker is blocking if the backlog is full. You can change it by setting is_blocking=false  
1. If the tracker is blocking -> tracker.track() will wait until there is space at the backlog  
2. If the tracker is not blocking -> tracker.track() will call the on_error callback if the backlog is full.

### Tracker onError

Case of failure the error_callback function will be called, which by default just logs the error to console
If you want to handle the error otherwise just overwrite the function (see example above).

### Low Level (Basic) SDK

The Low Level SDK has 2 methods:  
- putEvent - Sends a single event to Atom  
- putEvents - Sends a bulk (batch) of events to Atom.

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
## Change Log

### v1.5.2
- Fixed a bug with too many running threads in celluloid
- Added limits to Bulk Length, Size and Flush Interval
- Changed integration test to use multiple threads
- More verbose error handling
- The tracker is now blocking by default


### v1.5.1
- Rewrote all async ops to work with celluloid
- Refactored Tracker
- Refactored Atom base class
- Refactored Http Client class
- Improved Docs
- Added a Dockerfile and docker-compose to run the SDK in a container

### v1.1.0
- Added Tracker

### v1.0.0
- Basic features - putEvent & putEvents

## Example

- You can use our [example](example) for sending data to Atom.
- To run the SDK in a Docker container:  
    - Get Docker and docker-compose
    - git clone https://github.com/ironSource/atom-ruby.git
    - Setup your stream and auth at the docker-compose (passed as env vars)
    - run: ```docker-compose up ```

## License
[MIT][license-url]

[license-image]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-url]: LICENSE
[travis-image]: https://travis-ci.org/ironSource/atom-ruby.svg?branch=master
[travis-url]: https://travis-ci.org/ironSource/atom-ruby
[coveralls-image]: https://coveralls.io/repos/github/ironSource/atom-ruby/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/ironSource/atom-ruby?branch=master
[docs-image]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-url]: https://ironsource.github.io/atom-ruby/
[gem-image]: https://badge.fury.io/rb/iron_source_atom.svg
[gem-url]: https://badge.fury.io/rb/iron_source_atom
