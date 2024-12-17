require './config/environment.rb'
$log_it = LogIt.new
require './bot.rb'
# Process.daemon(true, false)
settings = YAML.load_file('settings.yml')
bot_settings = settings['bot']
$log_it.log('ERROR: bot not defined in settings.yml', :red) if bot_settings.blank?
bot = Bot.new(
  rx_name: bot_settings['rx']['name'],
  rx_host: bot_settings['rx']['host'],
  tx_name: bot_settings['tx']['name'],
  tx_host: bot_settings['tx']['host'],
)
bot.monitor
