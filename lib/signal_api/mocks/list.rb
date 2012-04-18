require 'signal_api/mocks/api_mock'

module SignalApi
  class List
    include ApiMock

    mock_method(:create_subscription, :subscription_type, :contact, :options)

    def create_subscription_additional_info
      { :list_id => @list_id }
    end

    mock_method(:destroy_subscription, :subscription_type, :contact)

    def destroy_subscription_additional_info
      { :list_id => @list_id }
    end
  end
end
