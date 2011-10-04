# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{watchr}
  s.version = "0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{mynyml}]
  s.date = %q{2010-08-23}
  s.description = %q{Modern continious testing (flexible alternative to autotest).}
  s.email = %q{mynyml@gmail.com}
  s.executables = [%q{watchr}]
  s.files = [%q{bin/watchr}]
  s.homepage = %q{http://mynyml.com/ruby/flexible-continuous-testing}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{watchr}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Modern continious testing (flexible alternative to autotest)}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<every>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<every>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<every>, [">= 0"])
  end
end
