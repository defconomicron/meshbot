require './config/environment.rb'
$log_it = LogIt.new
require './bot.rb'
settings = YAML.load_file('settings.yml')
bot_settings = settings['bot']
$log_it.log('ERROR: bot not defined in settings.yml', :red) if bot_settings.blank?
bot = Bot.new(
  rx_name: bot_settings['rx']['name'],
  rx_host: bot_settings['rx']['host'],
  tx_name: bot_settings['tx']['name'],
  tx_host: bot_settings['tx']['host']
)
Notice.order(:order).limit(3).each do |notice|
  bot.send_msg(notice.message, 0)
  sleep 15
end
sleep 60
# Notice.create(number: 1, message: "If you are new here, consider joining us on Facebook's Oklahoma Meshtastic Group @ https://tinyurl.com/2bxtyf4r or on Discord @ https://tinyurl.com/2bsm2f4j")
# Notice.create(number: 2, message: "Join us on OKieCorral with a PSK of BQ== as a secondary channel!  This channel (unlike LongFast) will bridge to the local LoRa mesh.")
# Notice.create(number: 3, message: "Thus preventing those without MQTT from hearing one-sided conversations. Additionally, it enables remote management of nodes over MQTT!")
