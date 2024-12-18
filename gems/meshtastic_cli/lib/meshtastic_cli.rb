class MeshtasticCli
  def initialize(options)
    require 'json/repair'
    require 'pty'
    @host = options[:host]
    @name = options[:name]
  end

  def packets(&block)
    PTY.spawn("meshtastic --host #{@host} --listen") do |stdout, stdin, pid|
      packet = nil
      stdout.each do |line|
        $log_it.log "[#{@name}] RAW: #{line.strip}"
        str = line.strip
        str = str.force_encoding('UTF-8')
        if str =~ /DEBUG/
          packet = str << "\n"
        elsif packet.present?
          packet << str << "\n"
        end
        if packet.present? && str =~ /\}/
          case packet
            when /packet/
              packet = packet.split('packet')[1].strip rescue ''
              packet = JSON.repair(packet) rescue nil
              packet = JSON.parse(packet) rescue nil
              yield({"packet" => packet}) if packet.present?
            when /node_info/
              packet = packet.split('node_info')[1].strip rescue ''
              packet = JSON.repair(packet) rescue nil
              packet = JSON.parse(packet) rescue nil
              yield({"node_info" => packet}) if packet.present?
            end
          packet = nil
        end
      end
    end
  rescue Exception => e
    $log_it.log "[#{@name}] EXCEPTION: #{e}: #{e.backtrace}", :red
    sleep 60
    retry
  end
end
