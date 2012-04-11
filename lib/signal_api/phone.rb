class Phone

  # Clean up phone number by removing special characters and country codes (if provided)
  def self.sanitize(phone_number)
    return nil if phone_number.nil?

    # Remove all non-numeric characters, ex - "=", "+", "(", ")", ".", "a", "A", " "
    sanitized_phone_number = phone_number.gsub(/[^\d]/, '')

    # Remove the US/Canadian country code (+1) if was provided
    if sanitized_phone_number.length > 10 && sanitized_phone_number[0,1] == "1"
      sanitized_phone_number = sanitized_phone_number[1, sanitized_phone_number.size]
    end

    sanitized_phone_number
  end

  # Return a 10 digit phone number for a given UMDA string (ie. tel:3120001111)
  def self.umda_to_phone_number(umda)
    if umda.downcase.include? "tel:"
      phone_number = umda.downcase.split("tel:")[1]
      phone_number
    elsif umda.length == 10
      umda
    end
  end

  def self.valid?(phone_number)
    return false if phone_number.nil? || phone_number.strip.empty?
    return false if self.sanitize(phone_number).size != 10
    return true
  end

  def self.format(phone_number, international=false)
    if Phone.valid?(phone_number)
      phone_number = Phone.sanitize(phone_number)
      unless international
        "#{phone_number[0..2]}-#{phone_number[3..5]}-#{phone_number[6..9]}" # 312-343-1326
      else
        phone_number
      end
    end
  end

end
