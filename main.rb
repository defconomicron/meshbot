require './config/environment.rb'
$log_it = LogIt.new
require './tx_bot.rb'
require './rx_bot.rb'
# Process.daemon(true, false)
settings = YAML.load_file('settings.yml')
bot_settings = settings['bot']
$log_it.log('ERROR: bot not defined in settings.yml', :red) if bot_settings.blank?
$tx_bot = TxBot.new(
  name: bot_settings['tx']['name'],
  host: bot_settings['tx']['host']
)
$tx_bot.monitor
$rx_bot = RxBot.new(
  name: bot_settings['rx']['name'],
  host: bot_settings['rx']['host']
)
$rx_bot.monitor
