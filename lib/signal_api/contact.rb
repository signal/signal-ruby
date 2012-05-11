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

    # Update the contact's data on the Signal platform.
    #
    # @return true If the contact's data was saved successfully.
    def save
      validate_contact_update

      xml = Builder::XmlMarkup.new
      xml.user_attributes do
        attributes.each do |key, value|
          xml.tag!(key, value)
        end
      end

      contact_identifier = mobile_phone.blank? ? email_address : mobile_phone

      with_retries do
        response = put("/api/contacts/#{contact_identifier}.xml",
                       :body => xml.target!,
                       :format => :xml,
                       :headers => common_headers)

        if response.code == 200
          true
        else
          handle_api_failure(response)
        end
      end
    end

    private

    def validate_contact_update
      raise InvalidParameterException.new("mobile_phone or email is required") if mobile_phone.blank? && email_address.blank?
      raise InvalidParameterException.new("nothing to update, only identifier provided") if attributes.count < 2
    end

  end
end
