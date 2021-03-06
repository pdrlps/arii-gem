# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arii/version'

Gem::Specification.new do |spec|
  spec.name = "arii"
  spec.version = ARII::VERSION
  spec.authors = ["Pedro Lopes"]
  spec.email = ["hello@pedrolopes.net"]
  spec.summary = %q{arii client library for distributed agents.}
  spec.description = %q{ARiiP: integrate everything. Automated real-time integration & interoperability platform.}
  spec.homepage = "https://ariip.com//"
  spec.license = "CC Attribution-NonCommercial-NoDerivatives 4.0 International"
  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'rest-client', '< 3'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'rubyXL'
  spec.add_runtime_dependency 'spreadsheet'
  spec.add_runtime_dependency 'jsonpath', '~> 0'
  spec.add_runtime_dependency 'tiny_tds', '> 0.6.3.rc1'
  spec.add_runtime_dependency 'pg'
end
