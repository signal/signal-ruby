require 'signal_api/mocks/api_mock'

module SignalApi
  class ShortUrl
    include ApiMock

    mock_class_method(:create, :target, :domain)
  end
end
