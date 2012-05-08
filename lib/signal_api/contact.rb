module SignalApi

  # A Contact (person, subscriber, etc) on the Signal platform
  class Contact

    # The user attributes associated with the contact
    attr_accessor :attributes

    def initialize(attributes={})
      @attributes = attributes
    end

    # Convenience accessor for the contact's mobile phone
    def mobile_phone
      @attributes['mobile-phone']
    end

    # Convenience accessor for the contact's email address
    def email_address
      @attributes['email-address']
    end

    def save
      validate_contact_update

      xml = Builder::XmlMarkup.new
      xml.user_attributes {
        attributes.each do |key, value|
          xml.tag!(key, value)
        end
      }

      response = with_retries do
        put("/api/contacts/#{mobile_phone}",
            :body => xml.target!,
            :format => :xml,
            :headers => common_headers)
      end

      if response.code == 200
        true
      else
        handle_api_failure(response)
      end
    end

    private

    def validate_contact_update
      raise InvalidParameterException.new("mobile_phone is required") if mobile_phone.blank?
      raise InvalidParameterException.new("nothing to update, only mobile phone provided") if attributes.count < 2
    end

  end
end
