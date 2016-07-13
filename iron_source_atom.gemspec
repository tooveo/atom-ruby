# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atom_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "iron_source_atom"
  spec.version       = IronSourceAtom::VERSION
  spec.authors       = ["Kirill Bokhanov"]
  spec.email         = ["kirill.bokhanov@ironsrc.com"]

  spec.summary       = "This is the official ironSource.atom gem"
  spec.description   = "Use this gem to send events to ironSource.atom data pipeline"
  spec.homepage      = "https://github.com/ironSource/atom-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "simplecov", "~> 1"
end
