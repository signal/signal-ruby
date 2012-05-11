module SignalApi

  # manage a copuon group using signals api
  class CouponGroup < SignalHttpApi

    # Consume a coupon
    #
    # @param [String] coupon_group_tag The tag for the coupon group in Textme to consume this coupon from.]
    # @param [String] mobile_phone The mobile phone to consume this coupon for
    #
    # @return a coupon code 
    def self.consume_coupon(coupon_group_tag, mobile_phone)
      validate_consume_coupon_parameters(coupon_group_tag, mobile_phone)

      SignalApi.logger.info "Attempting to consume coupon from group #{coupon_group_tag} #{mobile_phone}"

      xml = Builder::XmlMarkup.new
      xml.request do
        xml.user do
          xml.tag!('mobile_phone',mobile_phone)
        end
        xml.tag!('coupon_group', coupon_group_tag)
      end

      with_retries do
        response = get('/api/coupon_groups/consume_coupon.xml',
                       :body => xml.target!,
                       :format => :xml,
                       :headers => common_headers)

        if response.code == 200
          response.parsed_response['coupon_code']
        else
          handle_api_failure(response)
        end
      end
    end

    private

    def self.validate_consume_coupon_parameters(coupon_group_tag, mobile_phone)
      raise InvalidParameterException.new("Coupon group tag cannot be blank") if coupon_group_tag.blank?
      raise InvalidParameterException.new("Mobile_phone cannot be blank") if mobile_phone.blank?
    end

  end
end
