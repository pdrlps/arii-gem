# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i2x/version'

Gem::Specification.new do |spec|
  spec.name          = "i2x"
  spec.version       = I2X::VERSION
  spec.authors       = ["Pedro Lopes"]
  spec.email         = ["hello@pedrolopes.net"]
  spec.summary       = %q{i2x client library for distributed agents.}
  spec.description   = %q{i2x: integrate everything. Automated real-time integration framework.}
  spec.homepage      = "https://bioinformatics.ua.pt/i2x/"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
