# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wonder_navigation/version'

Gem::Specification.new do |spec|
  spec.name          = "wonder_navigation"
  spec.version       = WonderNavigation::VERSION
  spec.authors       = ["Douglas Lise", "Rodrigo Rosa"]
  spec.email         = ["douglaslise@gmail.com"]

  spec.summary       = "Rails Wonderful Navigation"
  spec.description   = "Describe your Rails' menus and breadcrumbs in a single place, with support for permissions, fixed and resource based labels."
  spec.homepage      = "http://github.com/douglaslise/wonder_navigation"
  spec.licenses      = ['MIT']

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rails", "~> 4.2"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.10"
  spec.add_development_dependency "byebug", "~> 6.0"
end
