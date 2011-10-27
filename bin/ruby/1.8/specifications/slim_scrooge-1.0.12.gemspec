# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "slim_scrooge"
  s.version = "1.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stephen Sykes"]
  s.date = "2011-09-28"
  s.description = "Slim scrooge boosts speed in Rails ActiveRecord Models by only querying the database for what is needed."
  s.email = "sdsykes@gmail.com"
  s.extensions = ["ext/Rakefile"]
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["README.textile", "ext/Rakefile"]
  s.homepage = "http://github.com/sdsykes/slim_scrooge"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Slim_scrooge - serious optimisation for ActiveRecord"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
