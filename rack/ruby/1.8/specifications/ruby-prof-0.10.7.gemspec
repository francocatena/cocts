# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-prof}
  s.version = "0.10.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Shugo Maeda, Charlie Savage, Roger Pack, Stefan Kaes}]
  s.date = %q{2011-05-09}
  s.description = %q{ruby-prof is a fast code profiler for Ruby. It is a C extension and
therefore is many times faster than the standard Ruby profiler. It
supports both flat and graph profiles.  For each method, graph profiles
show how long the method ran, which methods called it and which
methods it called. RubyProf generate both text and html and can output
it to standard out or to a file.
}
  s.email = %q{shugo@ruby-lang.org, cfis@savagexi.com, rogerdpack@gmail.com, skaes@railsexpress.de}
  s.executables = [%q{ruby-prof}]
  s.extensions = [%q{ext/ruby_prof/extconf.rb}]
  s.files = [%q{bin/ruby-prof}, %q{ext/ruby_prof/extconf.rb}]
  s.homepage = %q{http://rubyforge.org/projects/ruby-prof/}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.4")
  s.rubyforge_project = %q{ruby-prof}
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{Fast Ruby profiler}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<os>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
    else
      s.add_dependency(%q<os>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
    end
  else
    s.add_dependency(%q<os>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
  end
end
