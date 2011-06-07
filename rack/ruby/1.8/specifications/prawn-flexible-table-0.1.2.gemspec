# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{prawn-flexible-table}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jesús García Sáez}]
  s.date = %q{2010-03-18}
  s.description = %q{  An extension to Prawn that provides flexible table support, that means be able to create tables with rowspan and colspan attributes for each cell
}
  s.email = %q{blaxter@gmail.com}
  s.extra_rdoc_files = [%q{README}]
  s.files = [%q{README}]
  s.homepage = %q{http://github.com/blaxter/prawn-flexible-table}
  s.rdoc_options = [%q{--title}, %q{Prawn Documentation}, %q{--main}, %q{README}, %q{-q}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prawn}
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{An extension to Prawn that provides flexible table support}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
