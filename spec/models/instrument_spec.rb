# == Schema Information
# Schema version: 20120120165946
#
# Table name: instruments
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  instrument_id            :string(36)      not null
#  event_id                 :integer
#  instrument_type_code     :integer         not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)      not null
#  instrument_repeat_key    :integer
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_breakoff_code :integer         not null
#  instrument_status_code   :integer         not null
#  instrument_mode_code     :integer         not null
#  instrument_mode_other    :string(255)
#  instrument_method_code   :integer         not null
#  supervisor_review_code   :integer         not null
#  data_problem_code        :integer         not null
#  instrument_comment       :text
#  transaction_type         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  person_id                :integer
#  survey_id                :integer
#

require 'spec_helper'

describe Instrument do

  before(:each) do
    @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
    @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)
    @q = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "?",   :local_code => -4)
  end

  it "creates a new instance given valid attributes" do
    ins = Factory(:instrument)
    ins.should_not be_nil
  end

  it "describes itself in terms of the instrument type" do
    ins = Factory(:instrument)
    ins.to_s.should == ins.instrument_type.to_s
  end

  it { should belong_to(:psu) }
  it { should belong_to(:event) }
  it { should belong_to(:instrument_type) }
  it { should belong_to(:instrument_breakoff) }
  it { should belong_to(:instrument_status) }
  it { should belong_to(:instrument_mode) }
  it { should belong_to(:instrument_method) }
  it { should belong_to(:supervisor_review) }
  it { should belong_to(:data_problem) }

  it { should belong_to(:person) }
  it { should belong_to(:survey) }

  it { should have_one(:response_set) }

  it { should validate_presence_of(:instrument_version) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      ins = Factory(:instrument)
      ins.public_id.should_not be_nil
      ins.instrument_id.should == ins.public_id
      ins.instrument_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Instrument)

      ins = Instrument.new(:instrument_version => "0.1")
      ins.psu = Factory(:ncs_code)
      ins.event = Factory(:event)
      ins.save!

      obj = Instrument.first
      obj.instrument_type.local_code.should == -4
      obj.instrument_breakoff.local_code.should == -4
      obj.instrument_status.local_code.should == -4
      obj.instrument_mode.local_code.should == -4
      obj.instrument_method.local_code.should == -4
      # These values are defaulted to No
      obj.supervisor_review.local_code.should == 2
      obj.data_problem.local_code.should == 2
    end
  end

  describe "the breakoff code" do

    before(:each) do
      @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
      @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)
      create_missing_in_error_ncs_codes(Instrument)
    end

    it "should set the breakoff code to no if the reponse set has questions answered" do
      response_set = Factory(:response_set)
      response_set.stub!(:has_responses_in_each_section_with_questions?).and_return(true)

      instrument = Factory(:instrument)

      instrument.set_instrument_breakoff(response_set)
      instrument.instrument_breakoff.should == @n
    end


    it "should set the breakoff code to yes if the reponse set does not have questions answered in each section" do
      response_set = Factory(:response_set)
      response_set.stub!(:has_responses_in_each_section_with_questions?).and_return(false)

      instrument = Factory(:instrument)

      instrument.set_instrument_breakoff(response_set)
      instrument.instrument_breakoff.should == @y
    end

  end

  describe 'default code values' do
    {
      :supervisor_review => 'CONFIRM_TYPE_CL2',
      :data_problem => 'CONFIRM_TYPE_CL2',
      :instrument_mode => 'INSTRUMENT_ADMIN_MODE_CL1',
      :instrument_method => 'INSTRUMENT_ADMIN_METHOD_CL1'
    }.each do |attr, list|
      describe "for #{attr}" do
        let!(:default_code) {
          NcsCode.find_or_create_by_list_name_and_local_code(list, 2, :display_text => 'Foo')
        }

        let(:other_code) {
          NcsCode.find_or_create_by_list_name_and_local_code(list, 3, :display_text => 'Bar')
        }

        let(:new_instrument_attributes) {
          { :instrument_version => '0.0', :psu => Factory(:ncs_code), :event => Factory(:event) }
        }

        let(:new_instrument) {
          Instrument.new(new_instrument_attributes)
        }

        before do
          create_missing_in_error_ncs_codes(Instrument)
        end

        it 'defaults to 2' do
          new_instrument.save!
          Instrument.last.send(attr).should == default_code
        end

        it 'does not overwrite a set value' do
          new_instrument_attributes[attr] = other_code
          new_instrument.save!
          Instrument.last.send(attr).should == other_code
        end
      end
    end
  end
end
