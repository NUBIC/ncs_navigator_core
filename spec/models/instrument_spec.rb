# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: instruments
#
#  created_at               :datetime
#  data_problem_code        :integer          not null
#  event_id                 :integer
#  id                       :integer          not null, primary key
#  instrument_breakoff_code :integer          not null
#  instrument_comment       :text
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_id            :string(36)       not null
#  instrument_method_code   :integer          not null
#  instrument_mode_code     :integer          not null
#  instrument_mode_other    :string(255)
#  instrument_repeat_key    :integer          default(0), not null
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_status_code   :integer          not null
#  instrument_type_code     :integer          not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)       not null
#  lock_version             :integer          default(0)
#  person_id                :integer
#  psu_code                 :integer          not null
#  supervisor_review_code   :integer          not null
#  survey_id                :integer
#  transaction_type         :string(255)
#  updated_at               :datetime
#



require 'spec_helper'

require File.expand_path('../../shared/models/an_optimistically_locked_record', __FILE__)

describe Instrument do

  before(:each) do
    @y = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
    @n = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
    @q = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', -4)
  end

  it_should_behave_like 'an optimistically locked record' do
    subject { Factory(:instrument) }

    def modify(winner, loser)
      winner.instrument_comment = 'modified'
      loser.instrument_comment = 'also modified'
    end
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

  it { should have_many(:response_sets) }
  it { should have_many(:legacy_instrument_data_records) }
  it { should have_one(:contact_link) }

  it { should validate_presence_of(:instrument_version) }
  it { should validate_presence_of(:instrument_repeat_key) }

  describe '.start' do
    let(:event) { Factory(:event) }
    let(:person) { Factory(:person, :person_id => 'mother') }
    let(:mother) { Factory(:participant, :p_id => 'mother') }
    let(:child) { Factory(:participant, :p_id => 'child') }
    let(:survey) { Factory(:survey, :title => 'INS_QUE_BIRTH_INT_EHPBHI_P2_V2.0') }
    let(:survey_part) { Factory(:survey, :title => 'INS_QUE_BIRTH_INT_EHPBHI_P2_V2.0_BABY_NAME') }
    let(:inst) { Factory(:instrument, :survey => survey) }

    context 'a survey with one part' do
      describe 'if there is no response set for the (person, survey) pair' do
        it 'returns the result of Person#start_instrument' do
          person.should_receive(:start_instrument).with(survey, mother).and_return(inst)

          Instrument.start(person, mother, nil, survey, event).should == inst
        end

        it "sets the instrument's event to event" do
          inst = Instrument.start(person, mother, nil, survey, event)

          inst.event.should == event
        end
      end

      describe 'if there is a response set for the (person, survey) pair' do
        before do
          Factory(:response_set, :survey => survey, :user_id => person.id, :instrument => inst)
        end

        describe 'if the event is closed' do
          before do
            event.stub(:closed? => true)
          end

          it 'returns the result of Person#start_instrument' do
            person.should_receive(:start_instrument).with(survey, mother).and_return(inst)

            Instrument.start(person, mother, nil, survey, event).should == inst
          end

          it "sets the instrument's event to event" do
            inst = Instrument.start(person, mother, nil, survey, event)

            inst.event.should == event
          end
        end

        describe 'if the event is not closed' do
          before do
            event.stub(:closed? => false)
          end

          let(:i) { Instrument.start(person, mother, nil, survey, event) }

          it "returns the response set's instrument" do
            i.should == inst
          end

          it "has one response set" do
            i.response_sets.size.should == 1
          end

        end
      end
    end

    context 'a survey with more than one part' do

      context 'with an Instrument record created for the first part' do

        let!(:instrument) do
          i = Instrument.start(person, mother, nil, survey, event)
          i.save!
          i
        end

        describe 'the second survey part' do
          it 'returns the Instrument associated with the first part' do
            Instrument.start(person, child, survey, survey_part, event).should == instrument
          end

          it 'creates a response set about the participant sent (2nd parameter)' do
            instrument.response_sets.size.should == 1
            instrument.response_sets.first.person.should == person
            instrument.response_sets.first.participant.should == mother

            i = Instrument.start(person, child, survey, survey_part, event)
            i.should == instrument

            i.response_sets.size.should == 2
            i.response_sets.first.person.should == person
            i.response_sets.first.participant.should == mother
            i.response_sets.last.person.should == person
            i.response_sets.last.participant.should == child
          end

        end
      end
    end
  end

  describe '#response_set' do
    it 'is the inverse of ResponseSet#instrument' do
      Instrument.reflections[:response_sets].options[:inverse_of].should == :instrument
    end
  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      ins = Factory(:instrument)
      ins.public_id.should_not be_nil
      ins.instrument_id.should == ins.public_id
      ins.instrument_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      ins = Instrument.new(:instrument_version => "0.1", :instrument_repeat_key => 0)
      ins.event = Factory(:event)
      ins.save!

      obj = Instrument.first
      obj.instrument_type.local_code.should == -4
      obj.instrument_breakoff.local_code.should == -4
      obj.instrument_status.local_code.should == -4
      # These values are defaulted to No
      obj.instrument_mode.local_code.should == 2
      obj.instrument_method.local_code.should == 2
      obj.supervisor_review.local_code.should == 2
      obj.data_problem.local_code.should == 2
    end
  end

  describe "the breakoff code" do

    before(:each) do
      @y = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
      @n = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
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

  describe 'parsing information from psc' do

    context 'with label instrument:ins_que_24mmother_int_ehpbhi_p2_v1.0' do

      let(:lbl) { 'instrument:ins_que_24mmother_int_ehpbhi_p2_v1.0' }
      let(:code) { 'ins-bio-adultblood-dci-ehpbhi-p2-v1-0'}
      let(:title) { 'INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0' }

      describe '#determine_version' do
        it 'returns 1.0 for psc label' do
          Instrument.determine_version(lbl).should == "1.0"
        end

        it 'returns 1.0 for surveyor access code' do
          Instrument.determine_version(code).should == "1.0"
        end

        it 'returns 1.0 for survey title' do
          Instrument.determine_version(title).should == "1.0"
        end
      end

      describe "#parse_label" do
        it "returns the event portion of the label" do
          lbl = "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Instrument.parse_label(lbl).should == "ins_que_lipregnotpreg_int_li_p2_v2.0"
        end

        it "returns nil if label is blank" do
          lbl = ""
          Instrument.parse_label(lbl).should be_nil
        end

        it "returns nil if instrument portion is not included in label" do
          lbl = "event:low_intensity_data_collection"
          Instrument.parse_label(lbl).should be_nil
        end
      end

      describe "#collection?" do
        it "returns true if label denotes a collection activity" do
          lbl = "collection:biological event:pregnancy_visit_1 instrument:ins_bio_adulturine_dci_ehpbhi_p2_v1.0"
          Instrument.collection?(lbl).should be_true
        end

        it "returns false if label does not denote a collection activity" do
          lbl = "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Instrument.collection?(lbl).should be_false
        end
      end

    end

    context 'with label instrument:2.0:ins_que_24mmother_int_ehpbhi_p2_v1.0_part_one' do
      let(:lbl) { 'instrument:2.0:ins_que_24mmother_int_ehpbhi_p2_v1.0_part_one' }

      describe '#determine_version' do
        it 'returns 1.0 for psc label' do
          Instrument.determine_version(lbl).should == "1.0"
        end
      end
    end

    context 'with label instrument:2.0:ins_que_24mmother_int_ehpbhi_p2_v1.0' do

      let(:lbl) { 'instrument:2.0:ins_que_24mmother_int_ehpbhi_p2_v1.0' }
      let(:code) { 'ins-bio-adultblood-dci-ehpbhi-p2-v1-0'}
      let(:title) { 'INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0' }

      describe '#determine_version' do
        it 'returns 1.0 for psc label' do
          Instrument.determine_version(lbl).should == "1.0"
        end

        it 'returns 1.0 for surveyor access code' do
          Instrument.determine_version(code).should == "1.0"
        end

        it 'returns 1.0 for survey title' do
          Instrument.determine_version(title).should == "1.0"
        end
      end

      describe "#mdes_version" do
        it "returns mdes version from the instrument portion of the label" do
          Instrument.mdes_version(lbl).should == "2.0"
        end

        it "returns nil if label is blank" do
          Instrument.mdes_version("").should be_nil
        end

        it "returns nil if instrument portion is not included in label" do
          Instrument.mdes_version("event:low_intensity_data_collection").should be_nil
        end

        it "returns nil if mdes version is not in the instrument portion is not included in label" do
          Instrument.mdes_version("instrument:ins_que_24mmother_int_ehpbhi_p2_v1.0").should be_nil
        end

      end

      describe "#parse_label" do
        it "returns the instrument portion of the label" do
          lbl = "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Instrument.parse_label(lbl).should == "ins_que_lipregnotpreg_int_li_p2_v2.0"
        end

        it "returns nil if label is blank" do
          lbl = ""
          Instrument.parse_label(lbl).should be_nil
        end

        it "returns nil if instrument portion is not included in label" do
          lbl = "event:low_intensity_data_collection"
          Instrument.parse_label(lbl).should be_nil
        end
      end

      describe "#collection?" do
        it "returns true if label denotes a collection activity" do
          lbl = "collection:biological event:pregnancy_visit_1 instrument:ins_bio_adulturine_dci_ehpbhi_p2_v1.0 "
          Instrument.collection?(lbl).should be_true
        end

        it "returns false if label does not denote a collection activity" do
          lbl = "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
          Instrument.collection?(lbl).should be_false
        end
      end

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
          { :instrument_version => '0.0', :instrument_repeat_key => 0, :event => Factory(:event) }
        }

        let(:new_instrument) {
          Instrument.new(new_instrument_attributes)
        }

        before do
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

  describe '#link_to' do
    describe 'given a contact C, person P, event E, staff S, and instrument I' do
      let(:c) { Factory(:contact) }
      let(:p) { Factory(:person) }
      let(:e) { Factory(:event) }
      let(:i) { Factory(:instrument) }

      let(:staff_id) { 'staff' }

      describe 'if P is already linked to (C, E, S, I)' do
        before do
          @link = Factory(:contact_link, :contact => c, :person => p, :event => e, :staff_id => staff_id, :instrument => i)
        end

        it 'returns that link' do
          i.link_to(p, c, e, staff_id).should == @link
        end
      end

      describe 'if P is already linked to (C, E, S) but not I' do

        before do
          @link = Factory(:contact_link, :contact => c, :person => p, :event => e, :staff_id => staff_id, :instrument => i)
        end

        it 'returns that link' do
          i.link_to(p, c, e, staff_id).should == @link
        end

        it 'associates I with that link' do
          link = i.link_to(p, c, e, staff_id)
          link.instrument.should == i
        end

      end

      describe 'if P is not already linked to (C, E, I)' do
        describe 'the returned link' do
          let(:link) { i.link_to(p, c, e, staff_id) }

          it 'is unpersisted' do
            link.should be_new_record
          end

          it 'links to C' do
            link.contact.should == c
          end

          it 'links to P' do
            link.person.should == p
          end

          it 'links to E' do
            link.event.should == e
          end

          it 'links to I' do
            link.instrument.should == i
          end

          it 'links to the user who initiated the link' do
            link.staff_id.should == staff_id
          end

          it "has NcsNavigatorCore's psu_code" do
            link.psu_code.should == ::NcsNavigatorCore.psu_code.to_i
          end
        end
      end
    end
  end

  describe '#enumerable_to_warehouse?' do
    let(:event) { Factory(:mdes_min_event) }
    let(:instrument) { Factory(:instrument, :event => event) }

    let(:result) { instrument.enumerable_to_warehouse? }

    it 'is true when all requirements are met' do
      result.should be_true
    end

    it 'is false when there is no event associated with the instrument' do
      instrument.tap { |i| i.event = nil }.save!

      result.should be_false
    end

    it 'is false when the associated event has no disposition' do
      event.tap { |e| e.event_disposition = nil }.save!

      result.should be_false
    end
  end
end

