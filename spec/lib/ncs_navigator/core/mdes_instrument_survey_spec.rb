# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core
  describe MdesInstrumentSurvey do
    let(:instrument_text) {
      <<-INSTR
survey "INS_QUE_etc_v1.1" do
  section "Intro" do
    q_r_fname "First name",
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.R_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

    q_TUBE_STATUS_TUBE_TYPE_1_VISIT_1 "Blood tube collection status",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
  end
end
INSTR
    }

    subject { load_survey_string(instrument_text) }

    let(:questions) { subject.sections_with_questions.collect(&:questions).flatten }

    before do
      Survey.mdes_reset!
    end

    it 'is mixed into Survey' do
      ::Survey.ancestors.should include(MdesInstrumentSurvey)
    end

    describe '#mdes_table_map' do
      let(:map) { subject.mdes_table_map }

      it 'maps from associated table ident to variable name to question' do
        map['pre_preg'][:variables]['r_fname'][:questions].should ==
          [::Question.find_by_reference_identifier('r_fname')]
      end

      describe 'with fixed values' do
        it 'has the right the table name' do
          map['spec_blood_tube[tube_type=1]'][:table].should == 'spec_blood_tube'
        end

        it 'has the fixed value' do
          map['spec_blood_tube[tube_type=1]'][:variables]['tube_type'][:fixed_value].should == '1'
        end
      end

      describe 'with primary and secondary tables' do
        it 'is marked primary if it is primary' do
          map['pre_preg'][:primary].should be_true
        end

        it 'is not marked primary if it is not primary' do
          map['spec_blood_tube[tube_type=1]'][:primary].should be_false
        end
      end
    end

    describe '#mdes_other_pairs' do
      let(:instrument_text) {
        <<-INSTR
survey "INS_QUE_etc_v1.1" do
  section "Intro" do
    q_RENOVATE_ROOM "Which rooms were renovated?",
    :help_text => "Probe: Any others? Select all that apply.",
    :pick => :any,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_RENOVATE_ROOM.RENOVATE_ROOM"
    a_1 "Kitchen"
    a_2 "Living room"
    a_3 "Hall/landing"
    a_4 "{C_FNAME}’s bedroom"
    a_5 "Other bedroom"
    a_6 "Bathroom/toilet"
    a_7 "Basement"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_RENOVATE, "==", :a_1

    q_RENOVATE_ROOM_OTH "Other room",
    :pick => :one,
    :data_export_identifier=>"TWELVE_MTH_MOTHER_RENOVATE_ROOM.RENOVATE_ROOM_OTH"
    a "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A and B and C"
    condition_A :q_RENOVATE_ROOM, "==", :a_neg_5
    condition_B :q_RENOVATE_ROOM, "!=", :a_neg_1
    condition_C :q_RENOVATE_ROOM, "!=", :a_neg_2

    q_FORMULA_TYPE "Was the formula fed to your baby within the past 7 days ready-to-feed, liquid concentrate,
    powder from a can that makes more than one bottle, or powder from single serving packets?",
    :pick => :any,
    :data_export_identifier=>"SIX_MTH_SAQ_FORMULA_TYPE_2.FORMULA_TYPE"
    a_1 "Ready-to-feed"
    a_2 "Liquid concentrate"
    a_3 "Powder from a can that makes more than one bottle"
    a_4 "Powder from single serving packets"

    q_pet_type "What kind of pets are these?",
    :help_text => "Probe for any other responses. Select all that apply", :pick=>:any,
    :data_export_identifier=>"PREG_VISIT_1_PET_TYPE_2.PET_TYPE"
    a_1 "Dog"
    a_2 "Cat"
    a_3 "Small mammal (rabbit, gerbil, hamster, guinea pig, ferret, mouse)"
    a_4 "Bird"
    a_5 "Fish or reptile (turtle, snake, lizard)"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A"
    condition_A :q_pets, "==", :a_1

    q_pet_type_oth "Other types of pets", :pick=>:one, :data_export_identifier=>"PREG_VISIT_1_PET_TYPE_2.PET_TYPE_OTH"
    a_1 "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and B and C"
    condition_A :q_pet_type, "==", :a_neg_5
    condition_B :q_pet_type, "!=", :a_neg_1
    condition_C :q_pet_type, "!=", :a_neg_2

    q_RACE "What race do you consider yourself to be? You may select one or more.",
    :pick => :any,
    :data_export_identifier=>"FATHER_PV1_RACE.RACE"
    a_1 "White,"
    a_2 "Black or african american,"
    a_3 "American indian or alaska native,"
    a_4 "Asian, or"
    a_5 "Native hawaiian or other pacific islander?"
    a_6 "Multi-racial"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_AGE_ELIG, "!=", :a_2

    q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1 "Blood tube collection comments",
    :pick => :any,
    :data_export_identifier=>"SPEC_BLOOD_TUBE_COMMENTS[tube_type=1].TUBE_COMMENTS"
    a_1 "Equipment failure"
    a_2 "Fainting"
    a_3 "Light-headedness"
    a_4 "Hematoma"
    a_5 "Bruising"
    a_6 "Vein collapsed during procedure"
    a_7 "No suitable vein"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_TUBE_COMMENTS_OTH_TUBE_TYPE_1_VISIT_1 "Blood tube collection other comments",
    :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_COMMENTS_OTH"
    a_1 "Specify", :string

    q_TUBE_COMMENTS_TUBE_TYPE_3_VISIT_2 "Blood tube collection comments",
    :pick => :any,
    :data_export_identifier=>"SPEC_BLOOD_TUBE_COMMENTS[tube_type=3].TUBE_COMMENTS"
    a_1 "Equipment failure"
    a_2 "Fainting"
    a_3 "Light-headedness"
    a_4 "Hematoma"
    a_5 "Bruising"
    a_6 "Vein collapsed during procedure"
    a_7 "No suitable vein"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don’t know"

    q_TUBE_COMMENTS_OTH_TUBE_TYPE_3_VISIT_2 "Blood tube collection other comments",
    :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_COMMENTS_OTH"
    a_1 "Specify", :string

    q_REAS_TWQ_BL_N_COLLECTED "Why was the blank sample not collected?",
    :pick => :any,
    :data_export_identifier=>"TAP_WATER_TWQ_BLANK_COLLECTED.REAS_TWQ_BL_N_COLLECTED"
    a_1 "Supplies missing from kit"
    a_2 "Ran out of time"
    a_neg_5 "Other"
    dependency :rule=>"A"
    condition_A :q_TWQ_BLANK_COLLECT, "==", :a_2

    q_REAS_TWQ_BL_N_COLLECTED_OTH "Other reason the twq blank sample was not collected",
    :data_export_identifier=>"TAP_WATER_TWQ.REAS_TWQ_BL_N_COLLECTED_OTH"
    a "Specify:", :string

    q_hh_nonenglish_2 "What languages other than English are spoken in your home?",
    :pick =>:any,
    :data_export_identifier=>"PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH_2"
    a_1 "Spanish"
    a_2 "Arabic"
    a_3 "Chinese"
    a_4 "French"
    a_5 "French creole"
    a_6 "German"
    a_7 "Italian"
    a_8 "Korean"
    a_9 "Polish"
    a_10 "Russian"
    a_11 "Tagalog"
    a_12 "Vietnamese"
    a_13 "Urdu"
    a_14 "Punjabi"
    a_15 "Bengali"
    a_16 "Farsi"
    a_17 "Sign language"
    a_neg_5 "Other"
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule => "A"
    condition_A :q_hh_nonenglish, "==", :a_1

    q_hh_nonenglish_2_oth "Other languages that are spoken in your home",
    :pick=>:one,
    :data_export_identifier=>"PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH2_OTH"
    a_1 "Specify", :string
    a_neg_1 "Refused"
    a_neg_2 "Don't know"
    dependency :rule=>"A and B and C"
    condition_A :q_hh_nonenglish_2, "==", :a_neg_5
    condition_B :q_hh_nonenglish_2, "!=", :a_neg_1
    condition_C :q_hh_nonenglish_2, "!=", :a_neg_2
  end
end
INSTR
      }

      let(:pairs) { subject.mdes_other_pairs }

      it 'ignores pick=any questions with no other option' do
        pairs.select { |pair| pair[:coded].reference_identifier == 'FORMULA_TYPE' }.should == []
      end

      describe 'when there is an other question' do
        it 'makes the association when they are on the same table' do
          pairs.find { |pair| pair[:coded].reference_identifier == 'RENOVATE_ROOM' }[:other].should ==
            questions.find { |q| q.reference_identifier == 'RENOVATE_ROOM_OTH' }
        end

        {
          'PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH_2' =>
            'PREG_VISIT_1_NONENGLISH2_2.HH_NONENGLISH2_OTH'
        }.each do |coded_de, other_de|
          it "has an association override for #{coded_de} => #{other_de}" do
            pairs.find { |pair| pair[:coded].data_export_identifier == coded_de }[:other].should ==
              questions.find { |q| q.data_export_identifier == other_de }
          end
        end

        it 'makes the association when on the parent table' do
          pairs.find { |pair|
            pair[:coded].reference_identifier == 'REAS_TWQ_BL_N_COLLECTED'
          }[:parent_other].should ==
            questions.find { |q| q.reference_identifier == 'REAS_TWQ_BL_N_COLLECTED_OTH' }
        end

        it 'makes the association when on the parent table with a fixed value' do
          pairs.select { |pair|
            pair[:coded].reference_identifier =~ /^TUBE_COMMENTS_TUBE_TYPE/
          }.collect { |pair|
            [pair[:coded].reference_identifier, pair[:parent_other].reference_identifier]
          }.sort_by { |coded, other| coded }.should == [
            %w(TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1 TUBE_COMMENTS_OTH_TUBE_TYPE_1_VISIT_1),
            %w(TUBE_COMMENTS_TUBE_TYPE_3_VISIT_2 TUBE_COMMENTS_OTH_TUBE_TYPE_3_VISIT_2)
          ]
        end
      end

      it 'associates the coded question with nil if no other question is found' do
        pairs.detect { |pair| pair[:coded].reference_identifier == 'RACE' }[:other].should be_nil
      end
    end

    describe 'class methods' do
      before { subject }

      describe '.mdes_instrument_tables' do
        it 'returns the names of all instrument tables used in any survey' do
          Survey.mdes_instrument_tables.should == %w(pre_preg spec_blood_tube)
        end
      end

      describe '.mdes_primary_instrument_tables' do
        it 'returns the names of all primary instrument tables used in any survey' do
          Survey.mdes_primary_instrument_tables.should == %w(pre_preg)
        end
      end

      describe '.mdes_unused_instrument_tables' do
        it 'returns the names of all instrument tables that are not used in any survey' do
          Survey.mdes_unused_instrument_tables.should_not include('pre_preg')
          Survey.mdes_unused_instrument_tables.should_not include('spec_blood_tube')
          Survey.mdes_unused_instrument_tables.should include('household_enumeration')
        end
      end

      describe '.mdes_surveys_by_mdes_table' do
        it 'returns a mapping from MDES table to survey' do
          Survey.mdes_surveys_by_mdes_table.should ==
            { 'pre_preg' => subject, 'spec_blood_tube' => subject }
        end
      end
    end
  end
end