# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'duplicati/version'

Gem::Specification.new do |gem|
  gem.name          = "duplicati"
  gem.version       = Duplicati::VERSION
  gem.authors       = ["Jarmo Pertman"]
  gem.email         = ["jarmo.p@gmail.com"]
  gem.description   = %q{Duplicati backup utility wrapper in Ruby with easier API and sensible configuration defaults.}
  gem.summary       = %q{Duplicati backup utility wrapper in Ruby with easier API and sensible configuration defaults.}
  gem.homepage      = "https://github.com/jarmo/duplicati-rb"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
