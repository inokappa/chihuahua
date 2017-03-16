# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chihuahua/version'

Gem::Specification.new do |spec|
  spec.name          = "chihuahua"
  spec.version       = Chihuahua::VERSION
  spec.authors       = ["inokappa"]
  spec.email         = ["inokara@gmail.com"]

  spec.summary       = %q{Chihuahua is a tool to manage Datadog monitors.}
  spec.description   = %q{Chihuahua is a tool to manage Datadog monitors.}
  spec.homepage      = "https://github.com/inokappa/chihuahua"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency 'thor'
  spec.add_dependency 'diffy'
  spec.add_dependency 'dogapi'
  spec.add_dependency 'highline'
end
