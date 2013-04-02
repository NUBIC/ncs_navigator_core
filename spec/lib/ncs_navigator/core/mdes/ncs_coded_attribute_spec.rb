require 'spec_helper'

module NcsNavigator::Core::Mdes
  class Quux < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record

    ncs_coded_attribute :psu, :list_name => 'PSU_CL1'
    ncs_coded_attribute :event_type, :list_name => 'EVENT_TYPE_CL1'
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
        describe 'of NcsCode attribute' do
          it 'is reported valid when valid' do
            instance.event_type = an_event_type
            instance.should be_valid
          end

          it 'is valid when nil' do
            instance.event_type = nil
            instance.should be_valid
          end

          it 'is invalid when set to an NcsCode of the wrong list' do
            instance.event_type = NcsCode.for_list_name_and_local_code('PSU_CL1', -4)
            instance.should_not be_valid

            instance.errors[:event_type].should == [
              "wrong code list \"PSU_CL1\"; should be \"EVENT_TYPE_CL1\""
            ]
          end

          it 'is invalid when set to an NcsCode with an invalid code' do
            instance.event_type = NcsCode.new(:local_code => -100000, :list_name => 'EVENT_TYPE_CL1')
            instance.should_not be_valid

            instance.errors[:event_type_code].first.should =~
              /\Aillegal code value -100000; legal values are \[[\d,\- ]+\]\Z/
          end
        end

        describe 'of the coded value attribute' do
          it 'is valid when valid' do
            instance.event_type_code = 10
            instance.should be_valid
          end

          it 'is valid when nil' do
            instance.event_type_code = nil
            instance.should be_valid
          end

          it 'is valid when set to a String' do
            instance.event_type_code = "10"
            instance.should be_valid
          end

          it 'is invalid when set to an NcsCode with an invalid code' do
            instance.event_type_code = -900236
            instance.should_not be_valid

            instance.errors[:event_type_code].first.should =~
              /\Aillegal code value -900236; legal values are \[[\d,\- ]+\]\Z/
          end
        end
      end
    end

    describe '#list_name' do
      let(:attribute) {
        NcsCodedAttribute.new(nil, :foo_bar, :list_name => list_name_rules)
      }

      describe 'with a single list name' do
        let(:list_name_rules) { 'CONFIRM_TYPE_CL30' }

        it 'returns that list name' do
          attribute.list_name.should == 'CONFIRM_TYPE_CL30'
        end
      end

      describe 'with version-dependent list names' do
        let(:list_name_rules) {
          {
            'CONFIRM_TYPE_CL2' => '2.1',
            'CONFIRM_TYPE_CL3' => ['> 2.1', '< 3.0'],
            'CONFIRM_TYPE_CL4' => '>= 3.0'
          }
        }

        it 'selects the list matching the version exactly' do
          attribute.list_name('2.1').should == 'CONFIRM_TYPE_CL2'
        end

        it 'selects a list matching a range' do
          attribute.list_name('2.2').should == 'CONFIRM_TYPE_CL3'
        end

        it 'selects a list matching a sole criterion' do
          attribute.list_name('3.2').should == 'CONFIRM_TYPE_CL4'
        end

        it 'fails usefully if there is no list for the version' do
          expect { attribute.list_name('2.0') }.
            to raise_error(/No code list for foo_bar specified for MDES 2.0/)
        end

        it 'uses the system MDES version if none specified' do
          NcsNavigatorCore.should_receive(:mdes_version).and_return(Version.new('3.1'))

          attribute.list_name.should == 'CONFIRM_TYPE_CL4'
        end

        describe 'when more than one list name could match' do
          let(:list_name_rules) {
            {
              'CONFIRM_TYPE_CL2' => '2.1',
              'CONFIRM_TYPE_CL3' => ['>= 2.1', '< 3.0'],
              'CONFIRM_TYPE_CL4' => '>= 3.0'
            }
          }

          it 'fails' do
            expect { attribute.list_name('2.1') }.
              to raise_error('Ambiguous code list assigment for foo_bar in MDES 2.1: CONFIRM_TYPE_CL2, CONFIRM_TYPE_CL3')
          end
        end
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

      it 'fails usefully when there is no such code list' do
        NcsCode.should_receive(:for_list_name).with('EVENT_TYPE_CL1').and_return(nil)

        expect { actual }.to raise_error('No values found for code list "EVENT_TYPE_CL1"')
      end
    end
  end
end
