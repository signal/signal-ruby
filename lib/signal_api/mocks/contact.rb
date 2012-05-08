require 'signal_api/mocks/api_mock'

module SignalApi
  class Contact
    include ApiMock

    mock_method(:save)

    def save_additional_info
      { :attributes => @attributes }
    end
  end
end
