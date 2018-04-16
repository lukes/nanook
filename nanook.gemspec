
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "nanook/version"

Gem::Specification.new do |spec|
  spec.name          = "nanook"
  spec.version       = Nanook::VERSION
  spec.authors       = ["Luke Duncalfe"]
  spec.email         = ["lduncalfe@eml.cc"]

  spec.summary       = "Library for managing a nano currency node, including making and receiving payments, using the nano RPC protocol"
  spec.description   = "Library for managing a nano currency node, including making and receiving payments, using the nano RPC protocol"
  spec.homepage      = "https://github.com/lukes/nanook"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md CHANGELOG.md)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-collection_matchers", "~> 1.1"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.3"
  spec.add_development_dependency "webmock", "~> 3.3"
  spec.add_development_dependency "yard", "~> 0"

  spec.add_dependency "symbolized", "~> 0.0.1"

  spec.required_ruby_version = '>= 2.0'
end
