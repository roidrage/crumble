# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "crumble"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mathias Meyer"]
  s.date = "2010-11-05"
  s.description = "How did these breadcrumbs in your Rails application? Oh right, with this plugin!"
  s.email = "meyer@paperplanes.de"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://github.com/mattmatt/crumble"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Crumble - It's like breadcrumbs for your Rails application!"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
