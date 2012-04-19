require 'signal_api/mocks/api_mock'

module SignalApi
  class DeliverSms
    include ApiMock

    mock_method(:deliver, :mobile_phone, :message)

    def deliver_additional_info
      { :user_name => @username }
    end

  end
end
