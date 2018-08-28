# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "net-ldap-auth_adapter-gssapi"
  spec.version       = "0.2.0"
  spec.authors       = ["Ben Slusky"]
  spec.email         = ["bslusky@smartling.com"]

  spec.summary       = %q{Adapter for GSSAPI authentication in net-ldap gem}
  spec.description   = %q{This gem can be used with the net-ldap gem to perform GSSAPI authentication (which almost always means Kerberos authentication).}
  spec.homepage      = "https://github.com/syskill/ruby-net-ldap-gssapi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "gssapi"
  spec.add_runtime_dependency "net-ldap", "~> 0.12"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
