# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xpub/version'

Gem::Specification.new do |spec|
  spec.name          = 'xpub'
  spec.version       = Xpub::VERSION
  spec.authors       = ['Yoshihisa AMAKATA']
  spec.email         = ['amakata@gmail.com']
  spec.summary       = 'Xpub is EPUB and PDF publisher.'
  spec.description   = 'Xpub is EPUB and PDF publisher.'
  spec.homepage      = 'https://github.com/Amakata/xpub'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 11.1.2'

  spec.add_dependency 'rainbow', '~> 2.1.0'
  spec.add_dependency 'levenshtein', '~> 0.2.2'
end
