# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Mdes
  class Foo < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record

    ncs_coded_attribute :psu, 'PSU_CL1'
    ncs_coded_attribute :event_type, 'EVENT_TYPE_CL1'
  end

  class Bar < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record :public_id_field => :bar_id, :date_fields => [:start_date]
  end

  describe MdesRecord do
    before do
      ActiveRecord::Schema.define do
        suppress_messages do
          create_table :foos, :force => true do |t|
            t.string :name
            t.string :uuid

            t.integer :event_type_code
            t.integer :psu_code
          end

          create_table :bars, :force => true do |t|
            t.string :name
            t.string :bar_id

            t.date :start_date_date
            t.string :start_date
          end
        end
      end
    end

    after do
      ActiveRecord::Schema.define do
        suppress_messages do
          drop_table :foos
          drop_table :bars
        end
      end
    end

    describe '.public_id' do
      it 'defaults to :uuid' do
        Foo.public_id_field.should == :uuid
      end

      it 'is set from the :public_id_field option' do
        Bar.public_id_field.should == :bar_id
      end
    end

    describe '.date_fields' do
      it 'defaults to nil' do
        Foo.date_fields.should be_nil
      end

      it 'is set from :date_fields option' do
        Bar.date_fields.should == [:start_date]
      end
    end

    describe 'public ID' do
      describe 'readers' do
        let(:record) { Bar.new.tap { |b| b.bar_id = '77' } }

        it 'can be read as as #uuid' do
          record.uuid.should == '77'
        end

        it 'can be read with #public_id' do
          record.public_id.should == '77'
        end

        it 'can be read with the declared name' do
          record.bar_id.should == '77'
        end
      end

      it 'defaults to a UUID if not set' do
        Bar.create.public_id.length.should == 36
      end

      it 'defaults to a random UUID if not set' do
        Bar.create.public_id.should_not == Bar.create.public_id
      end
    end

    describe 'a date field' do
      let(:record) { Bar.new }

      it 'can be set from the modifier' do
        record.start_date_modifier = 'refused'
        record.save!
        record.start_date.should == '9111-91-91'
      end

      it 'can be set from a Date value' do
        record.start_date_date = Date.new(2013, 4, 16)
        record.save!
        record.start_date.should == '2013-04-16'
      end

      it 'can be set from a string date' do
        record.start_date = '2011-12-25'
        record.save!
        record.start_date_date.should == Date.new(2011, 12, 25)
      end

      it 'prefers the date set as a Date' do
        record.start_date = '2011-12-25'
        record.start_date_date = Date.new(2012, 2, 15)
        record.save!
        record.start_date.should == '2012-02-15'
      end
    end

    describe 'a coded attribute' do
      describe 'the ActiveRecord association' do
        let(:coded_association) { Foo.reflect_on_association(:psu) }

        it 'is created' do
          coded_association.should_not be_nil
        end

        it 'is associated to an NcsCode' do
          coded_association.options[:class_name].should == 'NcsCode'
        end

        it 'is limited to codes of the declared list' do
          coded_association.options[:conditions].should == "list_name = 'PSU_CL1'"
        end

        it 'uses a _code field to store the value' do
          coded_association.options[:foreign_key].should == :psu_code
        end

        it "refers to the NcsCode's local code" do
          coded_association.options[:primary_key].should == :local_code
        end
      end

      it 'exposes the list name' do
        Foo.ncs_coded_attributes[:psu].list_name.should == 'PSU_CL1'
      end
    end

    describe '.with_codes' do
      before do
        Foo.create
      end

      it 'exists on the model' do
        Foo.should respond_to(:with_codes)
      end

      it 'eager-loads codes' do
        Foo.with_codes.first.association(:event_type).should be_loaded
      end

      it 'supports eager-loading' do
        Foo.with_codes(:psu).first.association(:event_type).should_not be_loaded
      end
    end

    describe '#psu_code' do
      let!(:record) { Foo.create }

      it "is set to the center's first PSU on create" do
        record.psu_code.should == 20000030 # test config PSU
      end

      it 'can be set manually' do
        record.psu_code = 20000014
        record.save!
        record.psu_code.should == 20000014
      end
    end
  end
end
