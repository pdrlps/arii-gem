# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i2x/version'

Gem::Specification.new do |spec|
  spec.name          = "ARiiP"
  spec.version       = I2X::VERSION
  spec.authors       = ["Pedro Lopes"]
  spec.email         = ["hello@pedrolopes.net"]
  spec.summary       = %q{arii client library for distributed agents.}
  spec.description   = %q{ARiiP: integrate everything. Automated real-time integration & interoperability platform.}
  spec.homepage      = "http://stripe.pt/ariip/"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", '~> 0'

  spec.add_runtime_dependency 'rest-client', '~> 0'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'jsonpath', '~> 0'
end
