module SignalApi

  # Manage short URLs via Signal's URL shortening service
  class ShortUrl < SignalHttpApi

    # The shortened URL
    attr_reader :short_url

    # The target URL that was shortened
    attr_reader :target_url

    # The ID of the shortend URL on the Signal platform
    attr_reader :id

    # The domain of the short URL
    attr_reader :domain

    def initialize(id, target_url, short_url, domain)
      @id = id
      @target_url = target_url
      @short_url = short_url
      @domain = domain
    end

    # Create a short URL for the provided target URL
    #
    # @param [String] target The target URL that is to be shortened
    # @param [String] domain The short URL domain to use
    #
    # @return [ShortUrl] A ShortUrl object representing the short URL on the Signal platform
    def self.create(target, domain)
      body = <<-END
<short_url>
  <target_url><![CDATA[#{target}]]></target_url>
  <domain_id>1</domain_id>
</short_url>
      END

      SignalApi.logger.info "Attempting to create a short URL for #{target}"
      with_retries do
        response = post('/api/short_urls.xml',
                        :body => body,
                        :format => :xml,
                        :headers => common_headers)

        if response.code == 201
          data = response.parsed_response['short_url']
          new(data['id'], data['target_url'], "http://#{domain}/#{data['slug']}", domain)
        else
          handle_api_failure(response)
        end
      end
    end
  end

end
