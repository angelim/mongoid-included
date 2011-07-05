# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoid-included/version"

Gem::Specification.new do |s|
  s.name        = "mongoid-included"
  s.version     = Mongoid::Included::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Alexandre Angelim"]
  s.email = %q{angelim@angelim.com.br}  
  s.homepage = %q{http://github.com/angelim/mongoid-included}    
  s.summary = %q{Included namespaces documents for Mongoid}  
  s.description = %q{Helper to facilitate inclusion of namespaced documents in another Mongoid Document}
    
  s.rubyforge_project = "mongoid-included"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency("activemodel", ["~> 3.1.0.beta1"])
  s.add_runtime_dependency(%q<mongoid>, ["~> 2.0"])
  s.add_development_dependency("rspec", ["~> 2.6"])
  s.add_development_dependency("bson_ext", ["~> 1.3"])
  
end