require 'pty'

# DEBUG file:mesh_interface.py _handleFromRadio line:1060 Received from radio: packet {
#   from: 1136045656
#   to: 4294967295
#   channel: 3
#   decoded {
#     portnum: TEXT_MESSAGE_APP
#     payload: "@notice 1 Welcome to the Test channel!"
#     bitfield: 1
#   }
#   id: 10890508
#   rx_time: 1745115732
#   via_mqtt: true
#   hop_start: 4
# }

class MessageReceiver
  attr_accessor :pid, :hold

  def initialize
    raise Exception.new('settings.yml not defined') if $settings.blank?
    @meshtastic_cli_path = $settings['meshtastic_cli_path'] rescue nil
    raise Exception.new('meshtastic_cli_path not defined') if @meshtastic_cli_path.blank?
    @node_ip_address = $settings['node']['ip_address'] rescue nil
    raise Exception.new('node_ip_address not defined') if @node_ip_address.blank?
  end

  def receive(&block)
    while true
      begin
        perform_hold
        PTY.spawn(meshtastic_cli_cmd) do |stdout, stdin, pid|
          @pid = pid
          response = ''
          stdout.each do |line|
            throw_error(line)

            if line =~ /Received from radio: packet {/
              response << line << "\n"
              next
            elsif response.present? && !(line =~ /DEBUG/)
              response << line << "\n"
              next
            elsif response.blank?
              next
            end

            options = {
              id:                  get_value(response, 'id'),
              from:                get_value(response, 'from'),
              to:                  get_value(response, 'to'),
              short_name:          get_value(response, 'short_name').presence || get_value(response, 'shortName'),
              long_name:           get_value(response, 'long_name').presence || get_value(response, 'longName'),
              portnum:             get_value(response, 'portnum'),
              macaddr:             get_value(response, 'macaddr'),
              hw_model:            get_value(response, 'hw_model').presence || get_value(response, 'hwModel'),
              rx_time:             get_value(response, 'rx_time').presence || get_value(response, 'rxTime'),
              priority:            get_value(response, 'priority'),
              via_mqtt:            get_value(response, 'via_mqtt').presence || get_value(response, 'viaMqtt'),
              hop_start:           get_value(response, 'hop_start').presence || get_value(response, 'hopStart'),
              latitude:            get_value(response, 'latitude'),
              longitude:           get_value(response, 'longitude'),
              rx_snr:              get_value(response, 'rx_snr').presence || get_value(response, 'rxSnr'),
              rx_rssi:             get_value(response, 'rx_rssi').presence || get_value(response, 'rxRssi'),
              hop_limit:           get_value(response, 'hop_limit').presence || get_value(response, 'hopLimit'),
              altitude:            get_value(response, 'altitude'),
              time:                get_value(response, 'time'),
              channel:             get_value(response, 'channel'),
              location_source:     get_value(response, 'location_source').presence || get_value(response, 'locationSource'),
              ground_speed:        get_value(response, 'ground_speed').presence || get_value(response, 'groundSpeed'),
              ground_track:        get_value(response, 'ground_track').presence || get_value(response, 'groundTrack'),
              precision_bits:      get_value(response, 'precision_bits').presence || get_value(response, 'precisionBits'),
              latitude_i:          get_value(response, 'latitude_i').presence || get_value(response, 'latitudeI'),
              longitude_i:         get_value(response, 'longitude_i').presence || get_value(response, 'longitudeI'),
              bitfield:            get_value(response, 'bitfield'),
              battery_level:       get_value(response, 'battery_level').presence || get_value(response, 'batteryLevel'),
              voltage:             get_value(response, 'voltage'),
              channel_utilization: get_value(response, 'channel_utilization').presence || get_value(response, 'channelUtilization'),
              air_util_tx:         get_value(response, 'air_util_tx').presence || get_value(response, 'airUtilTx'),
              uptime_seconds:      get_value(response, 'uptime_seconds').presence || get_value(response, 'uptimeSeconds'),
              payload:             get_value(response, 'payload').try(:gsub, /^b'/,'')
            }.select {|k,v| v.present?}.with_indifferent_access
            yield(options) if options.present?
            response = ''
          end
        end
      rescue Exception => e
        report_exception(e)
        retry
      end
    end
    self
  end

  def kill
    if @pid.present?
      cmd = "kill -9 #{@pid}"
      log cmd, :yellow
      `#{cmd}`
      @pid = nil
    end
  end

  private

    def report_exception(e)
      log "Exception: #{e} #{e.backtrace}", :red
      log 'Restarting due to exception...'
    end

    def perform_hold
      log 'Holding...' if @hold
      while @hold;sleep 1;end
    end

    def meshtastic_cli_cmd
      str = "#{@meshtastic_cli_path} --host #{@node_ip_address} --listen"
      log str, :yellow
      str
    end

    def log(str, color = :black)
      $log_it.log "MessageReceiver: #{str}", color
    end

    def get_value(str, key)
      str.scan(/#{key}: ['"]*(.*?)['"]*(\r|\n|}|$)/).flatten.first.strip.force_encoding('UTF-8') rescue nil
    end

    def throw_error(line)
      raise Exception.new(line) if error?(line)
    end

    def error?(str)
      str =~ /connection reset by peer/i ||
      str =~ /broken pipe/i
    end
end