Process.daemon(true, false)

require './config/environment.rb'

$log_it.log 'LOADING SETTINGS...', :yellow

$thread = nil

require 'yaml'
$settings = YAML.load_file('settings.yml') rescue {}
raise Exception.new('settings.yml not defined') if $settings.blank?
$log_it.log 'settings.yml found', :green

$short_name = $settings['short_name'] rescue nil
raise Exception.new('short_name not defined in settings.yml') if $short_name.blank?
$log_it.log 'short_name found in settings.yml', :green

$long_name = $settings['long_name'] rescue nil
raise Exception.new('long_name not defined in settings.yml') if $long_name.blank?
$log_it.log 'long_name found in settings.yml', :green

$host = $settings['host'] rescue nil
raise Exception.new('host not defined in settings.yml') if $host.blank?
$log_it.log 'host found in settings.yml', :green

$meshtastic_path = $settings['meshtastic']['path'] rescue nil
raise Exception.new('meshtastic => path not defined in settings.yml') if $meshtastic_path.blank?
$log_it.log 'meshtastic => path found in settings.yml', :green

$max_text_length = $settings['max_text_length'] rescue nil
raise Exception.new('max_text_length not defined in settings.yml') if $max_text_length.blank?
$log_it.log 'max_text_length found in settings.yml', :green

$message_receiver = MessageReceiver.new
$message_processor = MessageProcessor.new.process
$message_transmitter = MessageTransmitter.new

while true;sleep 1;end;
