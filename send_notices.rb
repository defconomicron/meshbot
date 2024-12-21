require './config/environment.rb'
$log_it = LogIt.new
require './tx_bot.rb'
settings = YAML.load_file('settings.yml')
bot_settings = settings['bot']
$log_it.log('ERROR: bot not defined in settings.yml', :red) if bot_settings.blank?
$tx_bot = TxBot.new(
  name: bot_settings['tx']['name'],
  host: bot_settings['tx']['host']
)
$tx_bot.monitor
Notice.order(:order).each do |notice|
  $tx_bot.send_text(notice.message, notice.channel)
  sleep 15
end
sleep 60
# Notice.create(channel: 0, number: 1, message: "If you are new here, consider joining us on Facebook's Oklahoma Meshtastic Group @ https://tinyurl.com/2bxtyf4r or on Discord @ https://tinyurl.com/2bsm2f4j")
# Notice.create(channel: 0, number: 2, message: "Join us on OKieCorral with a PSK of BQ== as a secondary channel!  This channel (unlike LongFast) will bridge to the local LoRa mesh.")
# Notice.create(channel: 0, number: 3, message: "Thus preventing those without MQTT from hearing one-sided conversations. Additionally, it enables remote management of nodes over MQTT!")
