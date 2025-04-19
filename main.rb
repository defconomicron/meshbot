Process.daemon(true, false)

require './config/environment.rb'

$log_it.log 'LOADING SETTINGS...', :yellow

$thread = nil

require 'yaml'
$settings = YAML.load_file('settings.yml') rescue {}
raise Exception.new('settings.yml not defined') if $settings.blank?
$log_it.log 'settings.yml found', :green

$node_short_name = $settings['node']['short_name'] rescue nil
raise Exception.new('node => short_name not defined in settings.yml') if $node_short_name.blank?
$log_it.log 'node => short_name found in settings.yml', :green

$node_long_name = $settings['node']['long_name'] rescue nil
raise Exception.new('node => long_name not defined in settings.yml') if $node_long_name.blank?
$log_it.log 'node => long_name found in settings.yml', :green

$node_ip_address = $settings['node']['ip_address'] rescue nil
raise Exception.new('node => ip_address not defined in settings.yml') if $node_ip_address.blank?
$log_it.log 'node => ip_address found in settings.yml', :green

$meshtastic_cli_path = $settings['meshtastic_cli_path'] rescue nil
raise Exception.new('meshtastic_cli_path not defined in settings.yml') if $meshtastic_cli_path.blank?
$log_it.log 'meshtastic_cli_path found in settings.yml', :green

$max_text_length = $settings['max_text_length'] rescue nil
raise Exception.new('max_text_length not defined in settings.yml') if $max_text_length.blank?
$log_it.log 'max_text_length found in settings.yml', :green

$message_receiver = MessageReceiver.new
$message_processor = MessageProcessor.new.process
$message_transmitter = MessageTransmitter.new
NoticesBot.new.monitor

while true;sleep 1;end;
