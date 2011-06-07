# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ansi}
  s.version = "1.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Thomas Sawyer}, %q{Florian Frank}]
  s.date = %q{2011-05-05}
  s.description = %q{The ANSI project is a collection of ANSI escape code related libraries enabling ANSI code based colorization and stylization of output. It is very nice for beautifying shell output.}
  s.email = %q{rubyworks-mailinglist@googlegroups.com}
  s.extra_rdoc_files = [%q{README.rdoc}]
  s.files = [%q{README.rdoc}]
  s.homepage = %q{http://rubyworks.github.com/ansi}
  s.licenses = [%q{Apache 2.0}]
  s.rdoc_options = [%q{--title}, %q{ANSI API}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{ansi}
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{ANSI codes at your fingertips!}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<redline>, [">= 0"])
      s.add_development_dependency(%q<ko>, [">= 0"])
    else
      s.add_dependency(%q<redline>, [">= 0"])
      s.add_dependency(%q<ko>, [">= 0"])
    end
  else
    s.add_dependency(%q<redline>, [">= 0"])
    s.add_dependency(%q<ko>, [">= 0"])
  end
end
