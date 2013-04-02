# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: ncs_codes
#
#  created_at   :datetime
#  display_text :string(255)
#  id           :integer          not null, primary key
#  list_name    :string(255)
#  local_code   :integer
#  updated_at   :datetime
#

require 'spec_helper'

describe NcsCode do
  describe '.for_attributes' do
    it 'returns NCS codes for the given attributes' do
      NcsCode.for_attributes(:perm_closure_code, :psu_code).map(&:id).sort.should ==
        NcsCode.where(:list_name => ['CONFIRM_TYPE_CL10', 'PSU_CL1']).map(&:id).sort
    end

    it 'accepts strings for attribute names' do
      NcsCode.for_attributes('perm_closure_code', 'psu_code').map(&:id).sort.should ==
        NcsCode.where(:list_name => ['CONFIRM_TYPE_CL10', 'PSU_CL1']).map(&:id).sort
    end
  end

  it "should display attributes with user friendly method names (syntactic sugar)" do
    code = NcsCode.new(:display_text => 'foo', :local_code => 5)
    code.to_s.should == "#{code.display_text}"
    code.code.should == code.local_code
  end

  it { should validate_presence_of(:list_name) }
  it { should validate_presence_of(:display_text) }
  it { should validate_presence_of(:local_code) }

  context "finding event type using psc labels" do
    describe "#find_event_by_label" do
      [
        ["household_enumeration", "Household Enumeration"],
        ["pregnancy_probability", "Pregnancy Probability"],
        ["informed_consent", "Informed Consent"],
        ["pre-pregnancy_visit", "Pre-Pregnancy Visit"],
        ["pregnancy_visit_1", "Pregnancy Visit 1"],
        ["pregnancy_visit_2", "Pregnancy Visit 2"],
        ["birth", "Birth"],
        ["father", "Father"],
        ["validation", "Validation"],
        ["provider-based_recruitment", "Provider-Based Recruitment"],
        ["3_month", "3 Month"],
        ["6_month", "6 Month"],
        ["9_month", "9 Month"],
        ["12_month", "12 Month"],
        ["pregnancy_screener", "Pregnancy Screener"],
        ["18_month", "18 Month"],
        ["24_month", "24 Month"],
        ["low_to_high_conversion", "Low to High Conversion"],
        ["low_intensity_data_collection", "Low Intensity Data Collection"],
        ["other", "Other"],
        ["missing_in_error", "Missing in Error"],
      ].each do |lbl, txt|
        it %Q{maps "#{lbl}" to the code for "#{txt}"} do
          code = NcsCode.for_list_name_and_display_text("EVENT_TYPE_CL1", txt)
          NcsCode.find_event_by_lbl(lbl).should == code
        end
      end
    end
  end

  describe '.for_list_name' do
    let(:list_name) { 'EXPERIENCE_LEVEL_CL1' }
    let(:actual) { NcsCode.for_list_name(list_name) }

    it 'returns an array of NcsCodes' do
      actual.collect(&:class).uniq.should == [NcsCode]
    end

    it 'returns codes for the configured list only' do
      actual.collect(&:list_name).uniq.should == [list_name]
    end

    it 'returns the coded values for the configured list' do
      actual.collect(&:local_code).sort.should ==
        NcsCode.where(:list_name => list_name).collect(&:local_code).sort
    end
  end

  describe '.for_list_name_and_local_code' do
    let(:actual) { NcsCode.for_list_name_and_local_code('GENDER_CL2', 2) }

    it 'gives single NcsCode instance' do
      actual.should be_a NcsCode
    end

    it 'gives an instance for the correct code value' do
      actual.local_code.should == 2
    end

    it 'gives and instance for the correct list' do
      actual.list_name.should == 'GENDER_CL2'
    end

    it 'gives nil for an unknown list' do
      NcsCode.for_list_name_and_local_code('PICKLE_VARIETY_CL3', 1).should be_nil
    end

    it 'gives nil for an unknown code' do
      NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL10', 24).should be_nil
    end

    it 'works when the code is a string' do
      NcsCode.for_list_name_and_local_code('GENDER_CL2', '2').should be_a NcsCode
    end
  end

  describe '.for_list_name_and_display_text' do
    let(:actual) { NcsCode.for_list_name_and_display_text('GENDER_CL2', 'Female') }

    it 'gives single NcsCode instance' do
      actual.should be_a NcsCode
    end

    it 'gives an instance for the correct text' do
      actual.display_text.should == 'Female'
    end

    it 'gives and instance for the correct list' do
      actual.list_name.should == 'GENDER_CL2'
    end

    it 'gives nil for an unknown list' do
      NcsCode.for_list_name_and_display_text('PICKLE_VARIETY_CL3', 'Garlic').should be_nil
    end

    it 'gives nil for unknown text' do
      NcsCode.for_list_name_and_display_text('CONFIRM_TYPE_CL10', 'Most Assuredly').should be_nil
    end
  end

  describe '.for_attribute_name_and_local_code' do
    let(:actual) { NcsCode.for_attribute_name_and_local_code(:p_tracing_code, 2) }

    it 'uses the code list looked up from the attribute name' do
      actual.list_name.should == NcsCode.attribute_lookup(:p_tracing_code)
    end

    it 'gives the NcsCode for the specified value' do
      actual.local_code.should == 2
    end

    it 'passes along options to attribute_lookup' do
      expect { NcsCode.for_attribute_name_and_local_code(:refuser_strength_code, 1, :model_class => 'NonInterviewProvider') }.
        to_not raise_error
    end
  end

  describe '.ncs_code_lookup' do
    let(:actual) { NcsCode.ncs_code_lookup(:p_tracing_code) }

    it 'produces an array of pairs suitable for passing to a select helper' do
      NcsCode.ncs_code_lookup(:p_tracing_code).should == [
        ['Yes', 1],
        ['No', 2]
      ]
    end

    it 'omits Missing in Error by default' do
      NcsCode.ncs_code_lookup(:p_tracing_code).collect { |p| p.last }.
        should_not include(-4)
    end

    it 'will include Missing in Error by request with boolean' do
      NcsCode.ncs_code_lookup(:p_tracing_code, true).
        should include(['Missing in Error', -4])
    end

    it 'omits Missing in Error with an explicit option' do
      NcsCode.ncs_code_lookup(:p_tracing_code, :include_missing_in_error => false).collect { |p| p.last }.
        should_not include(-4)
    end

    it 'will include Missing in Error by request with an option' do
      NcsCode.ncs_code_lookup(:p_tracing_code, :include_missing_in_error => true).
        should include(['Missing in Error', -4])
    end

    it 'passes options to attribute_lookup' do
      expect { NcsCode.ncs_code_lookup('refuser_strength_code', :model_class => 'NonInterviewReport') }.
        to_not raise_error
    end
  end

  describe '.attribute_lookup' do
    it 'returns a code list name for a single known attribute symbol' do
      NcsCode.attribute_lookup('centrifuge_comment_code').should == 'SPECIMEN_STATUS_CL4'
    end

    it 'returns a code list name for a single known attribute string' do
      NcsCode.attribute_lookup(:centrifuge_comment_code).should == 'SPECIMEN_STATUS_CL4'
    end

    it 'returns nil for an unknown attribute' do
      NcsCode.attribute_lookup(:foobar).should be_nil
    end

    it 'is MDES version aware' do
      [
        NcsCode.attribute_lookup('text_permission_code', :mdes_version => '2.0'),
        NcsCode.attribute_lookup('text_permission_code', :mdes_version => '2.1')
      ].should == %w(CONFIRM_TYPE_CL2 CONFIRM_TYPE_CL10)
    end

    describe 'for an attribute which appears in multiple models' do
      it 'returns the sole code list when all the attributes use the same code list' do
        NcsCode.attribute_lookup('psu_code').should == 'PSU_CL1'
      end

      it 'fails when there is more than one code list possibility and no model is specified' do
        expect { NcsCode.attribute_lookup('refuser_strength_code') }.
          to raise_error("refuser_strength_code maps to 2 code lists in different models. Please use :model_class => 'Foo' to disambiguate.")
      end

      it 'returns the code list for the specified model when specified as a class' do
        NcsCode.attribute_lookup('refuser_strength_code', :model_class => NonInterviewProvider).
          should == 'REFUSAL_INTENSITY_CL2'
      end

      it 'returns the code list for the specified model when specified as a name' do
        NcsCode.attribute_lookup('refuser_strength_code', :model_class => 'NonInterviewReport').
          should == 'REFUSAL_INTENSITY_CL1'
      end

      it 'returns the code list for the specified model when specified as a symbol' do
        NcsCode.attribute_lookup('refuser_strength_code', :model_class => :NonInterviewReport).
          should == 'REFUSAL_INTENSITY_CL1'
      end

      it 'fails when the specified model does not have that attribute' do
        expect { NcsCode.attribute_lookup('refuser_strength_code', :model_class => 'Contact') }.
          to raise_error('Contact#refuser_strength_code is not a coded attribute (it may not be an attribute at all)')
      end
    end
  end
end

