module SignalApi

  # manage a copuon group using signals api
  class CouponGroup < SignalHttpApi

    # Consume a coupon
    #
    # @param [String] coupon_group_tag The tag for the coupon group in Textme to consume this coupon from.]
    # @param [String] mobile_phone The mobile phone to consume this coupon for
    #
    # @return [ShortUrl] A ShortUrl object representing the short URL on the Signal platform
    def self.consume_coupon(coupon_group_tag, mobile_phone)
      SignalApi.logger.info "Attempting to consume coupon from group #{coupon_group_tag} #{mobile_phone}"

      validate_consume_coupon_parameters(coupon_group_tag, mobile_phone)

      xml = Builder::XmlMarkup.new
      xml.request {
        xml.user {
          xml.tag!('mobile_phone',mobile_phone)
                 }
        xml.tag!('coupon_group', coupon_group_tag)
      }

      response = with_retries do
        get('/api/coupon_groups/consume_coupon.xml',
             :body => xml.target!,
             :format => :xml,
             :headers => common_headers)
      end

      if response.code == 200
        response.parsed_response['coupon_code']
      else
        handle_api_failure(response)
      end
    end

    private
    def self.validate_consume_coupon_parameters(coupon_group_tag, mobile_phone)
      if coupon_group_tag.blank?
        raise InvalidParameterException.new("Coupon group tag cannot be blank")
      end
      if mobile_phone.blank?
        raise InvalidParameterException.new("Mobile_phone cannot be blank")
      end
    end

  end

end
