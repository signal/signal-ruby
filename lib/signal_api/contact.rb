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

  end
end
