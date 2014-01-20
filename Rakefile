require 'picky/tasks'

namespace :spec do
  desc "Automatically run specs for updated files"
  task :kick do
    exec "bundle exec kicker -c"
  end
  
  desc "Run all specs"
  task :all do
    sh "bundle exec bacon -a -q"
  end
end

desc "Run all specs"
task :spec => 'spec:all'

task :default => :spec