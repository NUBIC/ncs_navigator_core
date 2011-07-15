require File.dirname(__FILE__) + '/test_helper' 
 
class ActsAsMdesRecordTest < Test::Unit::TestCase
  load_schema
  
  def test_a_foo_uuid_field_should_be_uuid
    assert_equal(:uuid, Foo.public_id_field)
  end
  
  def test_a_bar_uuid_field_should_be_bar_id
    assert_equal(:bar_id, Bar.public_id_field)
  end
  
  def test_uuid_returns_the_uuid
    bar = Bar.create
    assert_not_nil(bar.uuid)
    assert_equal(36, bar.uuid.length)
  end
  
  def test_public_id_returns_the_uuid
    bar = Bar.create
    assert_not_nil(bar.public_id)
    assert_equal(36, bar.public_id.length)
  end
  
  def test_all_uuid_accessors_return_the_same_value
    bar = Bar.create
    assert_equal(bar.uuid, bar.bar_id)
    assert_equal(bar.public_id, bar.bar_id)
    assert_equal(bar.public_id, bar.uuid)
  end
  
end


class Foo < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record
end

class Bar < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :bar_id
end