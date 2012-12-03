begin
  require 'rubygems/package_task'
  require 'rake/testtask'
rescue LoadError
end


Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test



