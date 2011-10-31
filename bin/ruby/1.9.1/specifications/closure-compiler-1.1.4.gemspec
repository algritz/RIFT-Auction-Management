# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "closure-compiler"
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Ashkenas", "Jordan Brough"]
  s.date = "2011-10-03"
  s.description = "    A Ruby Wrapper for the Google Closure Compiler.\n"
  s.email = "jeremy@documentcloud.org"
  s.homepage = "http://github.com/documentcloud/closure-compiler/"
  s.rdoc_options = ["--title", "Ruby Closure Compiler", "--exclude", "test", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "closure-compiler"
  s.rubygems_version = "1.8.11"
  s.summary = "Ruby Wrapper for the Google Closure Compiler"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
