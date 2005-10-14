require 'rake'
require 'rake/testtask'

task :default => [:run]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/unit/**/*_test.rb"
  #t.verbose = true
end
task :test => [:db]

task :db  do |t|
  sh "rm -f test/test.db"
  sh "sqlite3 test/test.db < data/neelix/create.sql"
end

desc 'rbuic'
task :ui do
  sh 'make -C lib/neelix/view/qt'
end

desc 'Run neelix'
task :run do
  ENV['NEELIX_UNINSTALLED'] = 'Heck Yes!'
  sh 'ruby -Ilib `pwd`/bin/neelix'
end

# vim: filetype=ruby
