Gem::Specification.new do |spec|
  spec.name          = "lita-icinga2"
  spec.version       = "0.0.5"
  spec.authors       = ["Martin Alfke"]
  spec.email         = ["tuxmea@gmail.com"]
  spec.description   = "Icinga 2 interaction with Lita"
  spec.summary       = "Receive notification and send ACK/recheck, etc. to Icinga 2"
  spec.homepage      = "https://github.com/tuxmea/lita-icinga2"
  spec.license       = "Apache License Version 2.0"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", "~> 4.0"
  spec.add_runtime_dependency "lita-keyword-arguments"
  spec.add_runtime_dependency "rest-client"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "rspec", ">= 3.0.0.beta2"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
