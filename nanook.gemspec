# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nanook/version'

DESCRIPTION = <<~DESC
  Library for managing a nano currency node, including making and
  receiving payments, using the nano RPC protocol
DESC

Gem::Specification.new do |spec|
  spec.name          = 'nanook'
  spec.version       = Nanook::VERSION
  spec.authors       = ['Luke Duncalfe']
  spec.email         = ['lduncalfe@eml.cc']

  spec.summary       = DESCRIPTION
  spec.description   = DESCRIPTION
  spec.homepage      = 'https://github.com/lukes/nanook'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('{bin,lib}/**/*') + %w[LICENSE.txt README.md CHANGELOG.md]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.

  spec.add_development_dependency 'bundler', '>= 2.2.10'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.2'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4'
  spec.add_development_dependency 'webmock', '~> 3.12'
  spec.add_development_dependency 'yard', '>= 0.9.20'

  spec.add_dependency 'symbolized', '= 0.0.1'

  spec.required_ruby_version = '>= 2.0'
end
