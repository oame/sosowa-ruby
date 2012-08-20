# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sosowa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Oame"]
  gem.email         = ["oame@oameya.com"]
  gem.description   = %q{Sosowa Parser for Ruby}
  gem.summary       = %q{Sosowa Parser for Ruby 1.9.x.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sosowa"
  gem.require_paths = ["lib"]
  gem.version       = Sosowa::VERSION
  gem.add_dependency "nokogiri"
end