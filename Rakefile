require 'picky/tasks'

namespace :spec do
  def specs dir = '**'
    FileList["spec/#{dir}/*_spec.rb"].shuffle.join ' '
  end
  
  desc "Automatically run specs for updated files"
  task :kick do
    exec "bundle exec kicker -c"
  end
  
  desc "Run all specs"
  task :all do
    sh "bundle exec bacon -q #{specs}"
  end
end

desc "Run all specs"
task :spec => 'spec:all'

task :default => :spec