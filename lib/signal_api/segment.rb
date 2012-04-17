module SignalApi

  # The type of segment
  class SegmentType
    DYNAMIC = "DYNAMIC"
    STATIC = "SEGMENT"
  end

  # Represents a user to be added to a segment
  class SegmentUser
    attr_reader :mobile_phone, :email_address, :user_data

    # Create a new segment on the Signal platform.
    #
    # @param [String] identifying_attribute The mobile phone or email address of the user
    # @param [Hash] user_data <b>Optional</b> A collection of key/value pairs to store along
    #                         with this user's segment record for later use
    def initialize(identifying_attribute, user_data={})
      if Phone.valid?(identifying_attribute)
        @mobile_phone = identifying_attribute
      elsif EmailAddress.valid?(identifying_attribute)
        @email_address = identifying_attribute
      else
        raise InvalidParameterException.new("identifying_attribute must be a valid mobile phone number or email address")
      end

      @user_data = user_data unless user_data.empty?
    end
  end

  # Create, manage, and add users to a segment.
  class Segment < SignalHttpApi

    # The name of the segment
    attr_reader :name

    # The description of the segment
    attr_reader :description

    # The ID of the segment
    attr_reader :id

    # The account_id of the segment
    attr_reader :account_id

    # Type type of the segment
    attr_reader :segment_type


    def initialize(id, name=nil, description=nil, segment_type=nil, account_id=nil)
      @name = name
      @description = description
      @id = id
      @account_id = account_id

      if segment_type == "DYNAMIC"
        @segment_type = SegmentType::DYNAMIC
      elsif segment_type == "SEGMENT"
        @segment_type = SegmentType::STATIC
      end
    end

    # Create a new segment on the Signal platform.
    #
    # @param [String] name The name of the segment
    # @param [String] description A description of the segment
    # @param [SegmentType] segment_type The type of the segment
    #
    # @return [Segment] A Segment object representing the segment on the Signal platform
    def self.create(name, description, segment_type)
      if name.blank? || description.blank? || segment_type.blank?
        raise InvalidParameterException.new("name, description, and segment_type are all required")
      end

      unless [SegmentType::DYNAMIC, SegmentType::STATIC].include?(segment_type)
        raise InvalidParameterException.new("Invalid segment type")
      end

      builder = Builder::XmlMarkup.new
      body = builder.filter_group do |filter_group|
        filter_group.description(description)
        filter_group.name(name)
        filter_group.filter_group_type(segment_type)
      end

      SignalApi.logger.info "Attempting to create a segment: name => #{name}, description => \"#{description}\", type = #{segment_type}}"
      SignalApi.logger.debug "Segment data: #{body}"
      response = with_retries do
        post("/api/filter_groups/create.xml",
             :body => body,
             :format => :xml,
             :headers => common_headers)
      end

      if response.code == 200
        data = response.parsed_response['subscription_list_filter_group']
        new(data['id'], data['name'], data['description'], lookup_segment_type(data['filter_group_type_id']), data['account_id'])
      else
        handle_api_failure(response)
      end
    end

    # Add mobile phone numbers to a segment.
    #
    # @param [Array<SegmentUser>] segment_users An array of SegmentUsers to add to the segment
    # @return [Hash] A hash containing some stats regarding the operation
    def add_users(segment_users)
      if segment_users.blank?
        raise InvalidParameterException.new("An array of SegmentUser objects must be provided")
      end

      builder = Builder::XmlMarkup.new
      body = builder.users(:type => :array) do |users|
        segment_users.each do |segment_user|
          users.user do |user|
            user.mobile_phone(segment_user.mobile_phone) if segment_user.mobile_phone
            user.email(segment_user.email_address) if segment_user.email_address
            user.user_data(segment_user.user_data) if segment_user.user_data
          end
        end
      end

      SignalApi.logger.info "Attempting to add users to segment #{@id}"
      response = self.class.with_retries do
        self.class.post("/api/filter_segments/#{@id}/update.xml",
                        :body => body,
                        :format => :xml,
                        :headers => self.class.common_headers)
      end

      if response.code == 200
        data = response.parsed_response['subscription_list_segment_results']

        if data['users_not_found'] && data['users_not_found']['user_not_found']
          SignalApi.logger.warn data['users_not_found']['user_not_found'].join(", ")
        end

        { :total_users_processed => (data['total_users_processed'] || 0).to_i,
          :total_users_added     => (data['total_users_added'] || 0).to_i,
          :total_users_not_found => (data['total_users_not_found'] || 0).to_i,
          :total_duplicate_users => (data['total_duplicate_users'] || 0).to_i }
      else
        self.class.handle_api_failure(response)
      end
    end

    private

    def self.lookup_segment_type(segment_type_id)
      case segment_type_id
      when 1 then SegmentType::DYNAMIC
      when 2 then SegmentType::STATIC
      end
    end

  end

end
