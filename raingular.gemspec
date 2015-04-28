# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raingular/version'

Gem::Specification.new do |spec|
  spec.name          = "raingular"
  spec.version       = Raingular::VERSION
  spec.authors       = ["Chris Moody"]
  spec.email         = ["cmoody@transcon.com"]
  spec.summary       = %q{Angular for rails v1.2.26.}
  spec.description   = %q{Angular is fastly evolving and has surpassed this version; however, no good convention over configuration assets exist and most of these methods have been developed using this version of angular.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib","vendor"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency 'angular-rails-templates'
end
