require 'test_helper'

class SegmentTest < Test::Unit::TestCase

  def setup
    SignalApi.api_key = 'foobar'
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end

  #
  # SegmentUser
  #
  should "raise an error if trying to create a SegmentUser with an identifying attribute that is not a mobile phone number or email address" do
    assert_raise SignalApi::InvalidParameterException do
      SignalApi::SegmentUser.new("foo")
    end
  end

  should "be able to create a SegmentUser with a mobile phone and user data" do
    segment_user = SignalApi::SegmentUser.new("3125551212", :foo_1 => 'bar_1', :foo_2 => 'bar_2')
    assert_equal "3125551212", segment_user.mobile_phone
    assert_equal Hash[:foo_1 => 'bar_1', :foo_2 => 'bar_2'], segment_user.user_data
  end

  should "be able to create a SegmentUser with an email address and user data" do
    segment_user = SignalApi::SegmentUser.new("john@test.com", :foo_1 => 'bar_1', :foo_2 => 'bar_2')
    assert_equal "john@test.com", segment_user.email_address
    assert_equal Hash[:foo_1 => 'bar_1', :foo_2 => 'bar_2'], segment_user.user_data
  end

  #
  # create
  #
  should "raise an error if any of the required parameters are missing" do
    assert_raise(SignalApi::InvalidParameterException) { SignalApi::Segment.create(nil, "description", SignalApi::SegmentType::STATIC) }
    assert_raise(SignalApi::InvalidParameterException) { SignalApi::Segment.create("", "description", SignalApi::SegmentType::STATIC) }
    assert_raise(SignalApi::InvalidParameterException) { SignalApi::Segment.create("name", nil, SignalApi::SegmentType::STATIC) }
    assert_raise(SignalApi::InvalidParameterException) { SignalApi::Segment.create("name", "", SignalApi::SegmentType::STATIC) }
    assert_raise(SignalApi::InvalidParameterException) { SignalApi::Segment.create("name", "description", nil) }
  end

  should "raise an exception if an invalid segment type is provided" do
    assert_raise(SignalApi::InvalidParameterException) { SignalApi::Segment.create("name", "description", "foo") }
  end

  should "be able to create a segment" do
    FakeWeb.register_uri(:post, SignalApi::SignalHttpApi::BASE_URI + '/api/filter_groups/create.xml', :content_type => 'application/xml', :status => ['200', 'Success'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<subscription-list-filter-group>
  <name>Segment 1</name>
  <created-at type="datetime">2012-04-13T18:58:50Z</created-at>
  <updated-at type="datetime">2012-04-13T18:58:50Z</updated-at>
  <account-id type="integer">1</account-id>
  <id type="integer">25</id>
  <filter-group-type-id type="integer">2</filter-group-type-id>
  <description>Test segment 1</description>
  <blast-only type="boolean">false</blast-only>
  <active type="boolean">true</active>
</subscription-list-filter-group>
END
    segment = SignalApi::Segment.create("Segment 1", "Test segment 1", SignalApi::SegmentType::STATIC)
    assert_equal 25, segment.id
    assert_equal "Segment 1", segment.name
    assert_equal "Test segment 1", segment.description
    assert_equal SignalApi::SegmentType::STATIC, segment.segment_type
    assert_equal 1, segment.account_id
  end

  should "raise an exception if unable to create the segment" do
    FakeWeb.register_uri(:post, SignalApi::SignalHttpApi::BASE_URI + '/api/filter_groups/create.xml', :content_type => 'application/xml', :status => ['422', 'Unprocessable Entity'], :body => <<-END)
<errors><error>name^A filter group with this name already exists</error></errors>
END
    assert_raise SignalApi::ApiException do
      SignalApi::Segment.create("Segment 1", "Test segment 1", SignalApi::SegmentType::STATIC)
    end
  end

  #
  # add_users
  #
  should "raise an error if no segment users were passed in" do
    assert_raise SignalApi::InvalidParameterException do
      segment = SignalApi::Segment.new(1)
      segment.add_users(nil)
    end
  end

  should "be able to add a collection of segment users to a static segment" do
    FakeWeb.register_uri(:post, SignalApi::SignalHttpApi::BASE_URI + '/api/filter_segments/1/update.xml', :content_type => 'application/xml', :status => ['200', 'Success'], :body => <<-END)
<subscription_list_segment_results>
  <users_not_found>
    <user_not_found>user with email john@test.com not found</user_not_found>
    <user_not_found>user with email bill@test.com not found</user_not_found>
  </users_not_found>
  <total_users_processed>4</total_users_processed>
  <total_users_added>2</total_users_added>
  <total_users_not_found>2</total_users_not_found>
  <total_duplicate_users>0</total_duplicate_users>
</subscription_list_segment_results>
END

    segment_users = [
      SignalApi::SegmentUser.new("3125551212", :foo_1 => 'bar 1', :foo_2 => 'bar 2'),
      SignalApi::SegmentUser.new("john@test.com", :foo_3 => 'bar 3', :foo_4 => 'bar 4'),
      SignalApi::SegmentUser.new("3125551213"),
      SignalApi::SegmentUser.new("bill@test.com")
    ]

    segment = SignalApi::Segment.new(1)
    results = segment.add_users(segment_users)
    assert_equal 2, results[:total_users_added]
    assert_equal 2, results[:total_users_not_found]
    assert_equal 0, results[:total_duplicate_users]
    assert_equal 4, results[:total_users_processed]
  end

  should "raise an exception if unable to add users to the segment" do
    FakeWeb.register_uri(:post, SignalApi::SignalHttpApi::BASE_URI + '/api/filter_segments/1/update.xml', :content_type => 'application/xml', :status => ['422', 'Success'], :body => <<-END)
<?xml version="1.0" encoding="UTF-8"?>
<error>
  <request>http://textme.dev/api/filter_segments/63/update.xml</request>
  <message>trying access invalid filter group</message>
</error>
END

    segment_users = [
      SignalApi::SegmentUser.new("3125551212", :foo_1 => 'bar 1', :foo_2 => 'bar 2'),
      SignalApi::SegmentUser.new("john@test.com", :foo_3 => 'bar 3', :foo_4 => 'bar 4'),
      SignalApi::SegmentUser.new("3125551213"),
      SignalApi::SegmentUser.new("bill@test.com")
    ]

    segment = SignalApi::Segment.new(1)
    assert_raise SignalApi::ApiException do
      segment.add_users(segment_users)
    end
  end

end
