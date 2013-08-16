# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash_verifier/version'

Gem::Specification.new do |gem|
  gem.name          = "hash_verifier"
  gem.version       = HashVerifier::VERSION
  gem.authors       = ["Martynas"]
  gem.email         = ["martynas@samesystem.dk"]
  gem.description   = %q{Gem to match hash structure to predefined pattern}
  gem.summary       = %q{Helps to verify that values in hash match values expected and hash adheres to required structure}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
