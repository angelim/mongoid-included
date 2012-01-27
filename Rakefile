$:.push File.expand_path("../lib", __FILE__)

require 'bundler'
require "rspec"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = %w(--format documentation)
  spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
task :test => :spec
