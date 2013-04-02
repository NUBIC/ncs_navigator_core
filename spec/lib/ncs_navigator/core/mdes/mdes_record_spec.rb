# -*- coding: utf-8 -*-

require 'spec_helper'

require File.expand_path('../../../../../shared/models/a_publicly_identified_record', __FILE__)

module NcsNavigator::Core::Mdes
  class Foo < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record

    ncs_coded_attribute :psu, 'PSU_CL1'
    ncs_coded_attribute :event_type, :list_name => 'EVENT_TYPE_CL1'
  end

  class Bar < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record :public_id_field => :bar_id, :date_fields => [:start_date]
  end

  class Baz < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record :public_id_field => :baz_id,
      :public_id_generator => HumanReadablePublicIdGenerator.new
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

          create_table :bazs, :force => true do |t|
            t.string :name
            t.string :baz_id
          end
        end
      end
    end

    after do
      ActiveRecord::Schema.define do
        suppress_messages do
          drop_table :foos
          drop_table :bars
          drop_table :bazs
        end
      end
    end

    it_should_behave_like 'a publicly identified record' do
      let(:o1) { Foo.create! }
      let(:o2) { Foo.create! }
    end

    describe '.models' do
      it 'includes all the models' do
        MdesRecord.models.should include(Baz)
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

    describe '.public_id_generator' do
      it 'has a default' do
        Foo.public_id_generator.should respond_to(:generate)
      end

      it 'is set from the :public_id_generator option' do
        Baz.public_id_generator.should be_a(HumanReadablePublicIdGenerator)
      end

      describe 'configuring' do
        it 'gives the generator the model class if it accepts it' do
          Baz.public_id_generator.model_class.should == Baz
        end

        it 'gives the generator the public ID field if it accepts it' do
          Baz.public_id_generator.public_id_field.should == :baz_id
        end
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

      describe 'generation' do
        describe 'by default' do
          it 'is a UUID if not set' do
            Bar.create.public_id.length.should == 36
          end

          it 'is a random UUID if not set' do
            Bar.create.public_id.should_not == Bar.create.public_id
          end
        end

        describe 'with a generator' do
          it 'uses the generator if the ID is not set' do
            expected_char_class = '[2-9abcdefhkrstwxyz]'
            Baz.create.public_id.should =~
              /^#{expected_char_class}{3}-#{expected_char_class}{2}-#{expected_char_class}{4}$/
          end
        end
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
      it 'exposes the list name' do
        Foo.ncs_coded_attributes[:psu].list_name.should == 'PSU_CL1'
      end

      it 'can be configured with a flat list name' do
        Foo.ncs_coded_attributes[:psu].list_name.should == 'PSU_CL1'
      end

      it 'can be configured with the list name in an options hash' do
        Foo.ncs_coded_attributes[:event_type].list_name.should == 'EVENT_TYPE_CL1'
      end
    end

    describe 'when coded values are left blank' do
      it 'sets them to -4 before validation' do
        f = Foo.new
        f.valid?
        f.event_type_code.should == -4
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
