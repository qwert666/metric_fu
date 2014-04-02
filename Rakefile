#!/usr/bin/env rake
require 'bundler/setup'

Dir['./gem_tasks/*.rake'].each do |task|
  import(task)
end

begin
  require 'spec/rake/spectask'
  desc "Run all specs in spec directory"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
rescue LoadError
  require 'rspec/core/rake_task'
  desc "Run all specs in spec directory"
  RSpec::Core::RakeTask.new(:spec)
end

require File.expand_path File.join(File.dirname(__FILE__),'lib/metric_fu')

require 'geminabox/rake'
Geminabox::Rake.install host: [ 'http://10.190.24.6:9292', 'http://10.190.28.15:9292' ]

task :default => :spec
