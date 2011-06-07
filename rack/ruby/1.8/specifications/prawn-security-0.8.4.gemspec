# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{prawn-security}
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Brad Ediger}]
  s.date = %q{2010-02-24}
  s.description = %q{  Prawn/Security adds document encryption, password protection, and permissions to Prawn.
}
  s.email = %q{brad.ediger@madriska.com}
  s.extra_rdoc_files = [%q{README}, %q{LICENSE}, %q{COPYING}]
  s.files = [%q{README}, %q{LICENSE}, %q{COPYING}]
  s.homepage = %q{http://github.com/madriska/prawn-security/}
  s.rdoc_options = [%q{--title}, %q{Prawn/Security Documentation}, %q{--main}, %q{README}, %q{-q}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prawn-security}
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{Popular Password Protection & Permissions for Prawn PDFs}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
