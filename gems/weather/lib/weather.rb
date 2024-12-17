($COMMAND_KEYWORDS ||=[]) << '@weather'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Weather.new.msg if /^@weather$/i =~ args[:payload]}
class Weather
  def initialize
  end

  def msg
    settings = YAML.load_file('settings.yml')
    api_endpoint = settings['weather_gem']['api_endpoint']
    return 'ERROR: Weather api_endpoint not defined.' if api_endpoint.blank?
    require 'active_support/core_ext/hash'
    response = Hash.from_xml(`curl #{api_endpoint}`)
    observation_time = response['current_observation']['observation_time']
    weather = response['current_observation']['weather'].strip rescue nil
    temp_f = response['current_observation']['temp_f'].strip rescue nil
    relative_humidity = response['current_observation']['relative_humidity'].strip rescue nil
    wind_string = response['current_observation']['wind_string'].strip rescue nil
    visibility_mi = response['current_observation']['visibility_mi'].strip rescue nil
    tokens = []
    tokens << "Currently, the weather is #{weather} with a temperature of #{temp_f} °F"
    tokens << "and a relative humidity of #{relative_humidity}% with winds from the #{wind_string}."
    tokens << "Visibility is #{visibility_mi} miles."
    tokens.join(' ').strip
  end
end

# https://api.weather.gov/alerts/active?area=WA
# {
#     "@context": [
#         "https://geojson.org/geojson-ld/geojson-context.jsonld",
#         {
#             "@version": "1.1",
#             "wx": "https://api.weather.gov/ontology#",
#             "@vocab": "https://api.weather.gov/ontology#"
#         }
#     ],
#     "type": "FeatureCollection",
#     "features": [
#         {
#             "id": "https://api.weather.gov/alerts/urn:oid:2.49.0.1.840.0.241d2d98ce5ee23b6619af2d96fc25069c0f5af2.001.1",
#             "type": "Feature",
#             "geometry": null,
#             "properties": {
#                 "@id": "https://api.weather.gov/alerts/urn:oid:2.49.0.1.840.0.241d2d98ce5ee23b6619af2d96fc25069c0f5af2.001.1",
#                 "@type": "wx:Alert",
#                 "id": "urn:oid:2.49.0.1.840.0.241d2d98ce5ee23b6619af2d96fc25069c0f5af2.001.1",
#                 "areaDesc": "Moses Lake Area; Upper Columbia Basin",
#                 "geocode": {
#                     "SAME": [
#                         "053001",
#                         "053025",
#                         "053017",
#                         "053043",
#                         "053047"
#                     ],
#                     "UGC": [
#                         "WAZ034",
#                         "WAZ035"
#                     ]
#                 },
#                 "affectedZones": [
#                     "https://api.weather.gov/zones/forecast/WAZ034",
#                     "https://api.weather.gov/zones/forecast/WAZ035"
#                 ],
#                 "references": [],
#                 "sent": "2024-12-09T09:53:00-08:00",
#                 "effective": "2024-12-09T09:53:00-08:00",
#                 "onset": "2024-12-09T09:53:00-08:00",
#                 "expires": "2024-12-09T13:00:00-08:00",
#                 "ends": null,
#                 "status": "Actual",
#                 "messageType": "Alert",
#                 "category": "Met",
#                 "severity": "Moderate",
#                 "certainty": "Observed",
#                 "urgency": "Expected",
#                 "event": "Special Weather Statement",
#                 "sender": "w-nws.webmaster@noaa.gov",
#                 "senderName": "NWS Spokane WA",
#                 "headline": "Special Weather Statement issued December 9 at 9:53AM PST by NWS Spokane WA",
#                 "description": "Patchy dense freezing fog with near zero visibility has been\nreported in the Columbia Basin this morning. Fog is particularly\ndense along Interstate 90 around Ritzville, US-2 between Wilbur\nand Coulee City, and WA-243 from Vantage to Desert Aire. Expect\nrapid changes in visibility in this area. Use extra caution,\nreduce speeds, and allow extra travel time. Fog is expected to\nlift this afternoon.",
#                 "instruction": null,
#                 "response": "Execute",
#                 "parameters": {
#                     "AWIPSidentifier": [
#                         "SPSOTX"
#                     ],
#                     "WMOidentifier": [
#                         "WWUS86 KOTX 091753"
#                     ],
#                     "BLOCKCHANNEL": [
#                         "EAS",
#                         "NWEM",
#                         "CMAS"
#                     ],
#                     "EAS-ORG": [
#                         "WXR"
#                     ]
#                 }
#             }
#         }
#     ],
#     "title": "Current watches, warnings, and advisories for Washington",
#     "updated": "2024-12-09T20:06:46+00:00"
# }