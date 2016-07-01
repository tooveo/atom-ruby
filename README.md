# ironSource.atom SDK for Ruby
[![License][license-image]][license-url]

Atom-Ruby is the official ironSource.atom SDK for the Ruby programming language.

- [Signup](https://atom.ironsrc.com/#/signup)

## Installation
```gem
$ gem install iron_source_atom-1.0.0.gem
```
## Using low level API methods
```ruby
require "test/unit"
require 'json'
require 'iron_source_atom'
class TestExample 
  def self.do_test_job
    auth = ""
    atom = IronSourceAtom.new(auth)
    data_string ={
        id: 1,
        message: "hello_from_ruby"
    }.to_json
    response = atom.put_event("ibtest", data_string)
    puts "Response #{response.code} #{response.message}:
          #{response.body}"

    data1={
        id: 11,
        message: "first_array_data"
    }
    data2={
        id: 12,
        message: "second_array_data"
    }
    data3={
        id: 13,
        message: "third_array_data"
    }
    array_data_string=[data1, data2, data3].to_json

    response =  atom.put_events("ibtest", array_data_string)
    puts "Response #{response.code} #{response.message}:
          #{response.body}"
  end
    do_test_job
end
```
### Example

You can use our [example][example-url] for sending data to Atom.

### License
MIT

[license-image]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-url]: LICENSE.txt

