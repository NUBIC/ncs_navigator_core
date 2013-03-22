require 'spec_helper'

module NcsNavigator::Core::Mdes
  class Quux < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record

    ncs_coded_attribute :psu, 'PSU_CL1'
    ncs_coded_attribute :event_type, 'EVENT_TYPE_CL1'
  end

  describe NcsCodedAttribute do
    before do
      ActiveRecord::Schema.define do
        suppress_messages do
          create_table :quuxes, :force => true do |t|
            t.string :name
            t.string :uuid

            t.integer :event_type_code
            t.integer :psu_code
          end
        end
      end
    end

    after do
      ActiveRecord::Schema.define do
        suppress_messages do
          drop_table :quuxes
        end
      end
    end

    describe 'the ActiveRecord association' do
      let(:coded_association) { Quux.reflect_on_association(:psu) }

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
  end
end
