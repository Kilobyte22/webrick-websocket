# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webrick/websocket/version'

Gem::Specification.new do |spec|
  spec.name          = 'webrick-websocket'
  spec.version       = WEBrick::Websocket::VERSION
  spec.authors       = ['Kilobyte22']
  spec.email         = ['stiepen22@gmx.de']
  spec.summary       = 'An extension for WEBrick to support websockets'
  spec.description   = ''
  spec.homepage      = 'https://github.com/Kilobyte22/webrick-websocket'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 12.3.3'

  spec.add_runtime_dependency 'webrick', '~> 1.3'
end
