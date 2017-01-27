# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atom_ruby/config'

Gem::Specification.new do |spec|
  spec.name          = "iron_source_atom"
  spec.version       = IronSourceAtom::VERSION
  spec.authors       = ["Atom Core Team"]
  spec.email         = ["atom-core@ironsrc.com"]

  spec.summary       = "This is the official ironSource.atom gem"
  spec.description   = "Use this gem to send events to ironSource.atom data pipeline"
  spec.homepage      = "https://github.com/ironSource/atom-ruby"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|gh-pages|example)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "celluloid", "~> 0.17"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "coveralls", '~> 0'
end
