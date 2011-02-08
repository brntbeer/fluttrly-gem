# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fluttrly-gem/version"

Gem::Specification.new do |s|
  s.name        = "fluttrly-gem"
  s.version     = Fluttrly::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brent Beer"]
  s.email       = ["brent.beer@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/fluttrly-gem"
  s.summary     = %q{Fluttrly.com command line interface.}
  s.description = %q{Maintain and inspect your fluttrly lists.}

  s.rubyforge_project = "fluttrly-gem"
	s.add_development_dependency "Hpricot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
