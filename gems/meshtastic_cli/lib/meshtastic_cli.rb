require 'json/repair'
require 'pty'

class MeshtasticCli
  def initialize(options)
    @host = options[:host]
  end

  def reboot
    $rx_bot.log "REBOOTING #{@host}!", :red
    `#{$meshtastic_path} --host #{@host} --reboot`
  end

  def get_value(str, key)
    str.scan(/['"]*#{key}['"]*: ['"]*(.*?)['"]*([,]|$)/).flatten.first rescue nil
  end

  def responses(&block)
    $rx_bot.log 'IGNORING RESPONSES FOR 30 SECONDS...', :yellow
    deaf = true
    Thread.new {
      sleep 30
      deaf = false
      $rx_bot.log 'NO LONGER IGNORING RESPONSES!', :yellow
    }
    PTY.spawn("#{$meshtastic_path} --host #{@host} --listen") do |stdout, stdin, pid|
      response = ''
      stdout.each do |line|
        next if deaf
        # $rx_bot.log "RAW: #{line.strip}"
        line = line.strip.force_encoding('UTF-8')
        raise Exception.new(line) if error?(line)
        if line =~ /DEBUG/ && response.present?
          _response = {
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
            payload:             get_value(response, 'payload')
          }.select {|k,v| v.present?}.with_indifferent_access
          yield _response if response.present? && response =~ /packet {/
          response = ''
        end
        response << line << "\n"
      end
    end
  end

  def error?(str)
    str =~ /BrokenPipeError/i ||
    str =~ /Connection reset by peer/i
  end
end
