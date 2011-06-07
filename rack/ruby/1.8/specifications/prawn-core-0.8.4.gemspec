# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{prawn-core}
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Gregory Brown}]
  s.date = %q{2010-02-24}
  s.description = %q{  Prawn is a fast, tiny, and nimble PDF generator for Ruby
}
  s.email = %q{  gregory.t.brown@gmail.com}
  s.extra_rdoc_files = [%q{HACKING}, %q{README}, %q{LICENSE}, %q{COPYING}]
  s.files = [%q{HACKING}, %q{README}, %q{LICENSE}, %q{COPYING}]
  s.homepage = %q{http://prawn.majesticseacreature.com}
  s.rdoc_options = [%q{--title}, %q{Prawn Documentation}, %q{--main}, %q{README}, %q{-q}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prawn}
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{A fast and nimble PDF generator for Ruby}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
