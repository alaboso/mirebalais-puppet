require 'rspec/core/rake_task'
require 'puppet-lint'
load 'tasks/whitespace.rake'

task :default => ['whitespace:check', :simplelint, :validate, :spec]

task :simplelint do
  linter = PuppetLint.new
  PuppetLint.configuration.with_filename = true
  PuppetLint.configuration.send("disable_80chars")
  PuppetLint.configuration.send("disable_documentation")
  Dir['mirebalais-modules/**/*.pp'].each do |pp|
    linter.file = pp
    linter.run
  end
  fail if linter.errors?
end

desc 'Validates the syntax of the puppet manifest files'
task :validate do
  puts `puppet parser validate #{Dir['**/*.pp'].join(' ')}`
  fail unless $?.to_i == 0
end

RSpec::Core::RakeTask.new(:spec) do |spec|
  file_list = FileList['spec/**/*_spec.rb']
  # file_list.exclude 'spec/whatever/...'
  spec.pattern = file_list
end
