# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{will_paginate}
  s.version = "3.0.pre2"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Mislav Marohnić}]
  s.date = %q{2010-02-04}
  s.description = %q{The will_paginate library provides a simple, yet powerful and extensible API for pagination and rendering of page links in web application templates.}
  s.email = %q{mislav.marohnic@gmail.com}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{LICENSE}, %q{CHANGELOG.rdoc}]
  s.files = [%q{README.rdoc}, %q{LICENSE}, %q{CHANGELOG.rdoc}]
  s.homepage = %q{http://github.com/mislav/will_paginate/wikis}
  s.rdoc_options = [%q{--main}, %q{README.rdoc}, %q{--charset=UTF-8}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{Adaptive pagination plugin for web frameworks and other applications}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
