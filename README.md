# meshbot

##### STEP 1 #####

  Add/edit the settings.yml file:
 
    bot:
      rx:
        name: Marco
        host: 192.168.1.23
      tx:
        name: Polo
        host: 192.168.1.24
    weather_gem:
      api_endpoint: https://forecast.weather.gov/xml/current_obs/KOKC.xml
    google_ai:
      api_key: AbCdEfGhIjKlMnOpQrStUvWxYz
    meshtastic:
      path: meshtastic

##### STEP 2 #####

  Command to create meshbot's database:
 
    bundle exec rake db:migrate

##### STEP 3 #####

  Add to your crontabs to automatically start the meshbot on boot:

    @reboot cd meshbot && /home/user/.rbenv/shims/ruby ~/meshbot/main.rb
