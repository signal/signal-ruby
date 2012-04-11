module SignalApi
  class ShortUrl < SignalHttpApi
    attr_reader :short_url, :target_url, :id, :domain

    def initialize(id, target_url, short_url, domain)
      @id = id
      @target_url = target_url
      @short_url = short_url
      @domain = domain
    end

    def self.create(target, domain)
      body = <<-END
<short_url>
  <target_url><![CDATA[#{target}]]></target_url>
  <domain_id>1</domain_id>
</short_url>
      END

      SignalApi.logger.info "Attempting to create a short URL for #{target}"
      response = post('/api/short_urls.xml',
                      :body => body,
                      :format => :xml,
                      :headers => {'api_token' => SignalApi.api_key})

      if response.code == 201
        data = response.parsed_response['short_url']
        new(data['id'], data['target_url'], "http://#{domain}/#{data['slug']}", domain)
      else
        handle_api_failure(response)
      end
    end
  end
end
