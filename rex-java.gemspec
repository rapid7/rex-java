# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rex/java/version'

Gem::Specification.new do |spec|
  spec.name          = "rex-java"
  spec.version       = Rex::Java::VERSION
  spec.authors       = ['Metasploit Hackers']
  spec.email         = ['msfdev@metasploit.com']

  spec.summary       = %q{Rex library for parsing serialized Java streams.}
  spec.description   = %q{Ruby Exploitation(Rex) library for parsing Java serialized streams.}
  spec.homepage      = "https://github.com/rapid7/rex-java"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
