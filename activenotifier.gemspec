# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: activenotifier 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "activenotifier"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Theodor Tonum"]
  s.date = "2015-05-11"
  s.description = "Simplifies sending notifications to your end users through multiple channels"
  s.email = "tt@skalar.no"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "Guardfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "activenotifier.gemspec",
    "lib/active_notifier.rb",
    "lib/active_notifier/base.rb",
    "lib/active_notifier/delivery_impossible.rb",
    "lib/active_notifier/transports.rb",
    "lib/active_notifier/transports/action_mailer.rb",
    "lib/active_notifier/transports/pushmeup.rb"
  ]
  s.homepage = "http://github.com/Skalar/activenotifier"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.6"
  s.summary = "Library for sending notifications to users"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 4.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<actionmailer>, ["~> 4.0"])
      s.add_development_dependency(%q<active_model_serializers>, ["~> 0.9.3"])
      s.add_development_dependency(%q<pushmeup>, ["~> 0.3.0"])
      s.add_development_dependency(%q<activejob>, ["~> 4.0"])
      s.add_development_dependency(%q<guard>, ["~> 2.0"])
      s.add_development_dependency(%q<guard-rspec>, ["~> 4.5.0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 4.0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<actionmailer>, ["~> 4.0"])
      s.add_dependency(%q<active_model_serializers>, ["~> 0.9.3"])
      s.add_dependency(%q<pushmeup>, ["~> 0.3.0"])
      s.add_dependency(%q<activejob>, ["~> 4.0"])
      s.add_dependency(%q<guard>, ["~> 2.0"])
      s.add_dependency(%q<guard-rspec>, ["~> 4.5.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 4.0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<actionmailer>, ["~> 4.0"])
    s.add_dependency(%q<active_model_serializers>, ["~> 0.9.3"])
    s.add_dependency(%q<pushmeup>, ["~> 0.3.0"])
    s.add_dependency(%q<activejob>, ["~> 4.0"])
    s.add_dependency(%q<guard>, ["~> 2.0"])
    s.add_dependency(%q<guard-rspec>, ["~> 4.5.0"])
  end
end

