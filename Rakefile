require 'pathname'
require 'rdoc/task'
require 'rspec/core/rake_task'


RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.add 'README.rdoc', 'LICENSE.txt', 'lib/**/*.rb'
end

RSpec::Core::RakeTask.new do |spec|
end


desc 'List all code todo lines'
task :todo do
  project_path = Pathname.new(__FILE__).dirname.expand_path
  search_paths = ['bin', 'lib', 'spec', 'util', 'Gemfile', 'kerbaldyn.gemspec']
  cmd = "grep --color -REn 'TODO' #{search_paths.map {|sp| project_path+sp}.join(' ')}"
  puts cmd
  puts '-' * 72
  exec(cmd)
end
