# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "query_trace"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathaniel Talbott", "Mike Gunderloy"]
  s.date = "2009-11-27"
  s.description = "With query_trace enabled, the Rails logs will contain a partial stack trace for every executed SQL statement, making it easier to find where they are generated in your code."
  s.email = "nathaniel@terralien.com"
  s.extra_rdoc_files = ["README", "MIT-LICENSE"]
  s.files = ["README", "MIT-LICENSE"]
  s.homepage = "http://github.com/ffmike/query_trace/tree/master"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Adds query origin tracing to your logs."

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
  end
end
