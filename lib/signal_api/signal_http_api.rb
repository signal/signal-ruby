module SignalApi
  class SignalHttpApi
    BASE_URI = "https://app.signalhq.com"

    include HTTParty
    base_uri BASE_URI
    default_timeout 5
  end
end
