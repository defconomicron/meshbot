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
          packet = packet.split('packet')[1].strip rescue ''
          packet = JSON.repair(packet) rescue nil
          packet = JSON.parse(packet) rescue nil
          yield packet if packet.present?
          packet = nil
        end
      end
    end
  end
end
