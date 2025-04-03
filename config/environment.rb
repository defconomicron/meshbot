require 'bundler'
Bundler.require
$log_it = LogIt.new
require './application.rb'
Dir.glob(['./lib/*.rb', './app/models/*.rb']).each {|file|
  $log_it.log "requiring: #{file}", :green
  require file
}
require 'sinatra/activerecord/rake'
