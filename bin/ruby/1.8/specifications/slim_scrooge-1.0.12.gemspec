# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{slim_scrooge}
  s.version = "1.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Stephen Sykes}]
  s.date = %q{2011-09-28}
  s.description = %q{Slim scrooge boosts speed in Rails ActiveRecord Models by only querying the database for what is needed.}
  s.email = %q{sdsykes@gmail.com}
  s.extensions = [%q{ext/Rakefile}]
  s.extra_rdoc_files = [%q{README.textile}]
  s.files = [%q{README.textile}, %q{ext/Rakefile}]
  s.homepage = %q{http://github.com/sdsykes/slim_scrooge}
  s.rdoc_options = [%q{--charset=UTF-8}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Slim_scrooge - serious optimisation for ActiveRecord}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
