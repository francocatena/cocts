# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fastthread}
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{MenTaLguY <mental@rydia.net>}]
  s.date = %q{2009-04-08}
  s.description = %q{Optimized replacement for thread.rb primitives}
  s.email = %q{mental@rydia.net}
  s.extensions = [%q{ext/fastthread/extconf.rb}]
  s.extra_rdoc_files = [%q{ext/fastthread/fastthread.c}, %q{ext/fastthread/extconf.rb}, %q{CHANGELOG}]
  s.files = [%q{ext/fastthread/fastthread.c}, %q{ext/fastthread/extconf.rb}, %q{CHANGELOG}]
  s.homepage = %q{}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Fastthread}]
  s.require_paths = [%q{lib}, %q{ext}]
  s.rubyforge_project = %q{mongrel}
  s.rubygems_version = %q{1.8.1}
  s.summary = %q{Optimized replacement for thread.rb primitives}

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
