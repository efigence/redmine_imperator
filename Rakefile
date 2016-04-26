require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test redmine_imperator plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for redmine_imperator plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'redmine_imperator'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
