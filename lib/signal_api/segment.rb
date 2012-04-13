module SignalApi

  # The type of segment
  class SegmentType
    DYNAMIC = "DYNAMIC"
    STATIC = "SEGMENT"
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


    def initialize(id, name, description, segment_type, account_id)
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
      response = post("/api/filter_groups/create.xml",
                      :body => body,
                      :format => :xml,
                      :headers => common_headers)

      if response.code == 200
        data = response.parsed_response['subscription_list_filter_group']
        new(data['id'], data['name'], data['description'], lookup_segment_type(data['filter_group_type_id']), data['account_id'])
      else
        handle_api_failure(response)
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
