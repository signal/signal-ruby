module SignalApi
  class EmailAddress

    # Check to see if an email address is valid
    def self.valid?(email)
      email && !email.strip.empty? && email.strip =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    end

  end
end
