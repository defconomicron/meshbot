require './config/environment.rb'
$log_it = LogIt.new
$log_it.log 'LOADING SETTINGS...', :yellow
begin
  require 'yaml'
  $settings = YAML.load_file('settings.yml') rescue {}
  raise Exception.new('settings.yml not defined') if $settings.blank?
  $log_it.log 'settings.yml found', :green

  $meshtastic_path = $settings['meshtastic']['path'] rescue nil
  raise Exception.new('meshtastic => path not defined in settings.yml') if $meshtastic_path.blank?
  $log_it.log 'meshtastic => path found in settings.yml', :green

  raise Exception.new('bot not defined in settings.yml') if $settings['bot'].blank?
  $log_it.log 'bot found in settings.yml', :green

  raise Exception.new('bot => rx not defined in settings.yml') if ($settings['bot']['rx'] rescue nil).blank?
  $log_it.log 'bot => rx found in settings.yml', :green
  raise Exception.new('bot => rx => name not defined in settings.yml') if ($settings['bot']['rx']['name'] rescue nil).blank?
  $log_it.log 'bot => rx => name found in settings.yml', :green
  raise Exception.new('bot => rx => host not defined in settings.yml') if ($settings['bot']['rx']['host'] rescue nil).blank?
  $log_it.log 'bot => rx => host found in settings.yml', :green
  $rx_bot = RxBot.new(name: $settings['bot']['rx']['name'], host: $settings['bot']['rx']['host'])

  raise Exception.new('bot => tx not defined in settings.yml') if ($settings['bot']['tx'] rescue nil).blank?
  $log_it.log 'bot => tx found in settings.yml', :green
  raise Exception.new('bot => tx => name not defined in settings.yml') if ($settings['bot']['tx']['name'] rescue nil).blank?
  $log_it.log 'bot => tx => name found in settings.yml', :green
  raise Exception.new('bot => tx => host not defined in settings.yml') if ($settings['bot']['tx']['host'] rescue nil).blank?
  $log_it.log 'bot => tx => host found in settings.yml', :green
  $tx_bot = TxBot.new(name: $settings['bot']['tx']['name'], host: $settings['bot']['tx']['host'])

  $max_text_length = $settings['bot']['tx']['max_text_length'] rescue nil
  raise Exception.new('bot => tx => max_text_length not defined in settings.yml') if $max_text_length.blank?
  $log_it.log 'bot => tx => max_text_length found in settings.yml', :green

  $sending_tries = $settings['bot']['tx']['sending_tries'] rescue nil
  raise Exception.new('bot => tx => sending_tries not defined in settings.yml') if $sending_tries.blank?
  $log_it.log 'bot => tx => sending_tries found in settings.yml', :green

  $log_it.log "[#{$rx_bot.name}] MONITORING!", :yellow
  $rx_bot.monitor
  $log_it.log "[#{$tx_bot.name}] MONITORING!", :yellow
  $tx_bot.monitor
  # $log_it.log "[#{$tx_bot.name}] DAEMONIZING...", :yellow
  # Process.daemon(true, true)
  # $log_it.log "[#{$tx_bot.name}] DAEMONIZED!", :yellow
  # NoticesBot.new.monitor

  while true;sleep 1;end;
rescue Exception => e
  $log_it.log("ERROR: #{e}", :red)
end
