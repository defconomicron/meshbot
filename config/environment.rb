require 'bundler'
Bundler.require
require './application.rb'
Dir.glob(['./lib/*.rb', './app/models/*.rb']).each {|file|
  puts "requiring: #{file}"
  require file
}
require 'sinatra/activerecord/rake'
