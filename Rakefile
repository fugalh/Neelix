require 'rake'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/unit/**/tc_*.rb"
  #t.verbose = true
end
task :test => [:db]

task :db  do |t|
  sh "rm -f test/test.db"
  sh "sqlite3 test/test.db < data/create.sql"
end

desc 'rbuic'
task :ui do
  sh 'make -C lib/neelix/view/qt'
end

# vim: filetype=ruby
