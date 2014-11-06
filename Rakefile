require 'picky/tasks'

namespace :db do
  namespace :test do
    
    task :bootstrap do
      sh 'pg_restore --verbose --clean --no-acl --no-owner -h localhost -d trunk_cocoapods_org_test spec/trunk.dump'
    end
    
  end
end

namespace :spec do
  def specs dir = '**'
    FileList["spec/#{dir}/*_spec.rb"].shuffle.join ' '
  end
  
  desc "Automatically run specs for updated files"
  task :kick do
    exec "bundle exec kicker -c"
  end
  
  desc "Run all specs"
  task :all => :'db:test:bootstrap' do
    sh "bundle exec bacon -q #{specs}"
  end
end

desc "Run all specs"
task :spec => 'spec:all'

task :default => :spec