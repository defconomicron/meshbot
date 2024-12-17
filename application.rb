class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :root, File.dirname(__FILE__)
  set :database, {adapter: 'sqlite3', database: 'db/bot.sqlite'}
  enable :logging
end