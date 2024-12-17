require './config/environment'
require 'sinatra/activerecord/rake'
Dir.glob('lib/tasks/*.rake').each {|r| load r}
task :console do
  Pry.start
end
require './application'