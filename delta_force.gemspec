# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "delta_force/version"

Gem::Specification.new do |s|
  s.name        = "delta_force"
  s.version     = DeltaForce::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joe Lind"]
  s.email       = ["joelind@gmail.com"]
  s.homepage    = "http://github.com/joelind/delta_force"
  s.summary     = %q{ActiveRecord named scopes with Postgres window functions.}
  s.description = %q{
      DeltaForce lets you use Postgres 8.4+ window functions with ActiveRecord
    }
  s.post_install_message = %q{
*** Thanks for installing DeltaForce! ***
}

  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]

  s.rubyforge_project = "delta_force"

  s.add_dependency 'activerecord', '~> 2.3.0'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ruby-debug'
  s.add_development_dependency 'pg'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
