# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_pusher/version'

Gem::Specification.new do |spec|
  spec.name          = "actionpusher"
  spec.version       = ActionPusher::VERSION
  spec.authors       = ["Magnus Hult"]
  spec.email         = ["magnus@magnushult.se"]

  spec.summary       = %q{Bla bla bla}
  spec.homepage      = "https://github.com/hult/actionpusher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "actionpack", "~> 5.0"
  spec.add_development_dependency "rpush"
  spec.add_development_dependency "rails", "~> 5.0", ">= 5.0.0.1"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "mocha"
end
