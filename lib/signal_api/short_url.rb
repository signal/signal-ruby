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

      response = post('/api/short_urls.xml',
                      :body => body,
                      :headers => {'api_token' => SignalApi.api_key, 'Content-Type' => 'application/xml'})

      if response.code == 201
        data = response.parsed_response['short_url']
        new(data['id'], data['target_url'], "http://#{domain}/#{data['slug']}", domain)
      else
        raise SignalApiException.new("Unable to create short url.  Respone body: #{response.body}")
      end
    end
  end
end
