lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wax_annotate/version'

Gem::Specification.new do |spec|
  spec.name          = 'wax_annotate'
  spec.version       = WaxAnnotate::VERSION
  spec.authors       = ['Marii']
  spec.email         = ['m.nyrop@columbia.edu']
  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.60'
end
