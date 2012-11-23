# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'presence/version'

Gem::Specification.new do |gem|
  gem.name          = "presence"
  gem.version       = Presence::VERSION
  gem.authors       = ["Jason Wadsworth"]
  gem.email         = ["jdwadsworth@gmail.com"]
  gem.description   = %q{Monitors the local network for presence of network clients by MAC address.}
  gem.summary       = %q{Plays theme music when d8:d1:cb:b3:af:c4 arrives.}
  gem.homepage      = "https://github.com/subakva/presence"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # gem.add_dependency('thor')

  gem.add_development_dependency('rake', ['~> 0.9.2'])
  gem.add_development_dependency('rspec', ['~> 2.11.0'])
  gem.add_development_dependency('cane', ['~> 2.3.0'])
  gem.add_development_dependency('simplecov', ['~> 0.7.1'])
end
