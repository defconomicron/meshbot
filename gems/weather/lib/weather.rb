($COMMAND_KEYWORDS ||=[]) << '@weather'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Weather.new(node: args[:node]).msg if /^@weather$/i =~ args[:payload]}
class Weather
  def initialize(options)
    @node = options[:node]
  end

  def msg
    return "Sorry, I don't quite know you just yet to be able to give you an accurate weather report.  Try again later on!" if @node.new_record?
    points_api_url = "https://api.weather.gov/points/#{@node.latitude.try(:round, 4)},#{@node.longitude.try(:round, 4)}"
    response = JSON.parse(`curl #{points_api_url}`)
    forecast_hourly_api_url = response['properties']['forecastHourly']
    response = JSON.parse(`curl #{forecast_hourly_api_url}`)
    period = response['properties']['periods'].first
    temperature = period['temperature']
    temperature_unit = period['temperatureUnit']
    short_forecast = period['shortForecast']
    relative_humidity = period['relativeHumidity']['value']
    wind_direction = period['windDirection']
    wind_speed = period['windSpeed']
    probability_of_percipitation = period['probabilityOfPrecipitation']['value']
    tokens = []
    tokens << "Currently, the weather where you're located is \"#{short_forecast}\""
    tokens << "with a temperature of #{temperature} °#{temperature_unit}"
    tokens << "and a relative humidity of #{relative_humidity}%"
    tokens << "with winds from the #{wind_direction} @ #{wind_speed}"
    tokens << "and a #{probability_of_percipitation}% chance of percipitation."
    tokens.join(' ')
  end
end
