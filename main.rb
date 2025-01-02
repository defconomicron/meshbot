require 'yaml'
$settings = YAML.load_file('settings.yml') rescue {}
$meshtastic_path = $settings['meshtastic']['path'] rescue nil
require './config/environment.rb'
$log_it = LogIt.new
$log_it.log('ERROR: settings.yml not defined', :red) if $settings.blank?
$log_it.log('ERROR: meshtastic path not defined in settings.yml', :red) if $meshtastic_path.blank?
# Process.daemon(true, false)
$log_it.log('ERROR: bot not defined in settings.yml', :red) if $settings['bot'].blank?
$tx_bot = TxBot.new(name: $settings['bot']['tx']['name'], host: $settings['bot']['tx']['host'])
$rx_bot = RxBot.new(name: $settings['bot']['rx']['name'], host: $settings['bot']['rx']['host'])
$tx_bot.monitor
NoticesBot.new.monitor
$rx_bot.monitor
while true;sleep 1;end;