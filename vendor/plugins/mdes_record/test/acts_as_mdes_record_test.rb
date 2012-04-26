# -*- coding: utf-8 -*-


require File.dirname(__FILE__) + '/test_helper'

class ActsAsMdesRecordTest < Test::Unit::TestCase
  load_schema

  def test_a_foo_public_id_field_should_be_uuid
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

  def test_create_date_modifier_is_set_on_date_fields
    df = DateFoo.new
    df.start_date_modifier = 'refused'
    df.save!
    assert_equal('9111-91-91', df.start_date)
  end

  def test_save_string_date_from_date
    df = DateFoo.new
    df.start_date_date = Date.today
    assert_equal(nil, df.start_date)
    df.save!
    assert_equal(Date.today.strftime('%Y-%m-%d'), df.start_date)
  end

  def test_save_date_from_string_date
    df = DateFoo.new
    df.start_date = '2011-12-25'
    assert_equal(nil, df.start_date_date)
    df.save!
    assert_equal(Date.parse('2011-12-25'), df.start_date_date)
  end

  def test_saving_date_overrides_string_date
    df = DateFoo.new
    df.start_date = '2011-12-25'
    df.start_date_date = Date.today
    df.save!
    assert_equal(Date.today.strftime('%Y-%m-%d'), df.start_date)
  end

  def test_date_fields_are_accessible
    df = DateFoo.new
    assert_equal(df.date_fields, [:start_date])
  end

  def test_coded_attribute_belongs_to_code_list_model
    assoc = Foo.reflect_on_association(:psu)
    assert_not_nil(assoc, 'association not created')
    assert_equal(
      "list_name = 'PSU_CL1'",
      assoc.options[:conditions])
    assert_equal(:psu_code, assoc.options[:foreign_key])
    assert_equal(:local_code, assoc.options[:primary_key])
  end

  def test_coded_attribute_list_name_retrievable
    Foo.ncs_coded_attributes[:psu].list_name == 'PSU_CL1'
  end
end


class Foo < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record

  ncs_coded_attribute :psu, 'PSU_CL1'
end

class Bar < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :bar_id
end

class DateFoo < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :date_fields => [:start_date]
end