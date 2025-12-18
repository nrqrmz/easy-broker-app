require 'net/http'
require 'json'

class LocationTool < RubyLLM::Tool
  description "Gets the user's approximate current location based on their IP address"

  def initialize(ip_address:)
    @ip_address = ip_address
  end

  def execute
    uri = URI("http://ip-api.com/json/#{@ip_address}?fields=status,message,country,regionName,city,lat,lon")
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    if data["status"] == "success"
      {
        city: data["city"],
        region: data["regionName"],
        country: data["country"],
        latitude: data["lat"],
        longitude: data["lon"]
      }
    else
      { error: "Could not determine location" }
    end
  rescue => e
    { error: e.message }
  end
end
