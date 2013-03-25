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

    describe 'model additions' do
      let(:instance) { Quux.new }

      let(:an_event_type_code) { 13 }
      let(:an_event_type) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', an_event_type_code) }
      let(:a_psu) { NcsCode.for_list_name_and_local_code('PSU_CL1', 20000209) }

      describe 'NcsCode accessors' do
        describe 'writer' do
          it 'accepts an NcsCode and sets the code attribute' do
            instance.event_type = an_event_type
            instance.event_type_code.should == an_event_type_code
          end

          it 'accepts a code value and sets the code attribute' do
            instance.event_type = an_event_type_code
            instance.event_type_code.should == an_event_type_code
          end

          it 'accepts display text and sets the code attribute' do
            pending 'Might be neat, but what is the appropriate response when invalid? Exception or ?'
            instance.event_type = an_event_type.display_text
            instance.event_type_code.should == an_event_type_code
          end

          it 'rejects other kinds of values' do
            expect { instance.event_type = true }.
              to raise_error(/Cannot resolve an NcsCode from true/)
          end

          it 'accepts nil and sets the code attribute to nil' do
            instance.event_type_code = an_event_type_code
            instance.event_type = nil
            instance.event_type_code.should be_nil
          end

          # the error will be reported in the validations
          it 'accepts an invalid NcsCode and sets the code attribute' do
            instance.event_type = a_psu
            instance.event_type_code.should == a_psu.local_code
          end
        end

        describe 'reader' do
          describe 'when the code alone is set' do
            it 'locates an NcsCode for the correct code' do
              instance.event_type_code = 15
              instance.event_type.local_code.should == 15
            end

            it 'locates an NcsCode for the correct list' do
              instance.event_type_code = 15
              instance.event_type.list_name.should == 'EVENT_TYPE_CL1'
            end

            it 'returns nil when the code is set to nil' do
              instance.event_type_code = nil
              instance.event_type.should be_nil
            end

            it 'returns nil when the code is not valid for the list' do
              instance.event_type_code = a_psu.local_code
              instance.event_type.should be_nil
            end
          end

          describe 'when an NcsCode is set' do
            it 'returns the same value' do
              instance.event_type = an_event_type
              instance.event_type.should be(an_event_type)
            end

            it 'returns the same value even if it is not valid' do
              instance.event_type = a_psu
              instance.event_type.should == a_psu
            end

            it 'returns nil when nil is set' do
              instance.event_type = nil
              instance.event_type.should be_nil
            end
          end
        end
      end

      describe 'foreign key accessors' do
        describe 'writer' do
          it 'triggers a change to the NcsCode value' do
            instance.event_type = an_event_type
            instance.event_type_code = 18
            instance.event_type.local_code.should == 18
          end
        end
      end

      describe 'validation' do
        it 'complains about an NcsCode of the wrong list'
        it 'complains about a coded value that is not acceptable'
      end
    end

    describe '#code_list' do
      let(:actual) { Quux.ncs_coded_attributes[:event_type].code_list }

      it 'returns an array of NcsCodes' do
        actual.collect(&:class).uniq.should == [NcsCode]
      end

      it 'returns codes for the configured list only' do
        actual.collect(&:list_name).uniq.should == ['EVENT_TYPE_CL1']
      end

      it 'returns the coded values for the configured list' do
        actual.collect(&:local_code).sort.should ==
          NcsCode.where(:list_name => 'EVENT_TYPE_CL1').collect(&:local_code).sort
      end
    end
  end
end
