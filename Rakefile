require 'rake'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/unit/**/*_test.rb"
  #t.verbose = true
end
task :test => [:db,:ui]

desc "Set up test/test.db"
task :db  do |t|
  sh "rm -f test/test.db"
  sh "sqlite3 test/test.db < data/neelix/create.sql"
end

desc 'rbuic'
task :ui do
  sh 'make -C lib/neelix/view/qt'
end

desc 'Finish the OS X bundle'
task :bundle => [:ui] do
  sh 'cp -r lib bin data Neelix.app/Contents/Resources'
  sh 'cd Neelix.app/Contents/Resources/; ln -sf bin/neelix rb_main.rb'
end

desc 'OS X .dmg file'
task :dmg => [:bundle] do
  sh 'hdiutil create -ov -srcfolder Neelix.app Neelix.dmg'
  sh 'hdiutil internet-enable -yes Neelix.dmg'
end


# vim: filetype=ruby
