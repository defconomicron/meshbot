require './config/environment.rb'
$log_it = LogIt.new

begin
  require 'yaml'
  $settings = YAML.load_file('settings.yml') rescue {}
  raise Exception.new('settings.yml not defined') if $settings.blank?

  $meshtastic_path = $settings['meshtastic']['path'] rescue nil
  raise Exception.new('meshtastic > path not defined in settings.yml') if $meshtastic_path.blank?

  raise Exception.new('bot not defined in settings.yml') if $settings['bot'].blank?

  raise Exception.new('bot > rx not defined in settings.yml') if ($settings['bot']['rx'] rescue nil).blank?
  raise Exception.new('bot > rx > name not defined in settings.yml') if ($settings['bot']['rx']['name'] rescue nil).blank?
  raise Exception.new('bot > rx > host not defined in settings.yml') if ($settings['bot']['rx']['host'] rescue nil).blank?
  $rx_bot = RxBot.new(name: $settings['bot']['rx']['name'], host: $settings['bot']['rx']['host'])

  raise Exception.new('bot > tx not defined in settings.yml') if ($settings['bot']['tx'] rescue nil).blank?
  raise Exception.new('bot > tx > name not defined in settings.yml') if ($settings['bot']['tx']['name'] rescue nil).blank?
  raise Exception.new('bot > tx > host not defined in settings.yml') if ($settings['bot']['tx']['host'] rescue nil).blank?
  $tx_bot = TxBot.new(name: $settings['bot']['tx']['name'], host: $settings['bot']['tx']['host'])

  $max_text_length = $settings['bot']['tx']['max_text_length'] rescue nil
  raise Exception.new('bot > tx > max_text_length not defined in settings.yml') if $max_text_length.blank?

  $sending_tries = $settings['bot']['tx']['sending_tries'] rescue nil
  raise Exception.new('bot > tx > sending_tries not defined in settings.yml') if $sending_tries.blank?
rescue Exception => e
  $log_it.log("ERROR: #{e}", :red)
end

$rx_bot.monitor
$tx_bot.monitor

# Process.daemon(true, false)
# NoticesBot.new.monitor

while true;sleep 1;end;
