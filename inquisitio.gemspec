# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inquisitio/version'

Gem::Specification.new do |spec|
  spec.name          = "inquisitio"
  spec.version       = Inquisitio::VERSION
  spec.authors       = ["Jeremy Walker", "Charles Care", "Malcolm Landon"]
  spec.email         = ["jeremy@meducation.net", "charles@meducation.net", "malcolm@meducation.net"]
  spec.description   = %q{A Ruby Gem that wraps search for CloudSearch}
  spec.summary       = %q{This wraps AWS CloudSearch in a Ruby Gem}
  spec.homepage      = "https://github.com/meducation/inquisition"
  spec.license       = "AGPL3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "excon", "~> 0.25.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "minitest", "~> 5.0.8"
end
