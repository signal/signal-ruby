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

end
