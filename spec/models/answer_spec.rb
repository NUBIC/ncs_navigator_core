# == Schema Information
# Schema version: 20130327150082
#
# Table name: answers
#
#  api_id                 :string(255)
#  common_identifier      :string(255)
#  common_namespace       :string(255)
#  created_at             :datetime
#  custom_class           :string(255)
#  custom_renderer        :string(255)
#  data_export_identifier :string(255)
#  default_value          :string(255)
#  display_length         :integer
#  display_order          :integer
#  display_type           :string(255)
#  help_text              :text
#  id                     :integer          not null, primary key
#  input_mask             :string(255)
#  input_mask_placeholder :string(255)
#  is_exclusive           :boolean
#  question_id            :integer
#  reference_identifier   :string(255)
#  response_class         :string(255)
#  short_text             :text
#  text                   :text
#  updated_at             :datetime
#  weight                 :integer
#

require 'spec_helper'

require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe Answer do
  it_should_behave_like 'a publicly identified record' do
    let(:o1) { Factory(:answer) }
    let(:o2) { Factory(:answer) }
  end

  describe "#custom_class_present?" do
    let(:answer) { Factory(:answer, :custom_class => custom_class) }

    describe "when custom class is not set" do
      let(:custom_class) { nil }
      it "returns false" do
        answer.custom_class_present?("asdf").should be_false
      end
    end

    describe "when single custom class set" do
      let(:custom_class) { "asdf" }

      it "returns true when present" do
        answer.custom_class_present?("asdf").should be_true
      end

      it "returns false when not present" do
        answer.custom_class_present?("1234").should be_false
      end

      it "returns false when inexact match" do
        answer.custom_class_present?("asd").should be_false
      end

    end

    describe "when multiple custom class set" do
      let(:custom_class) { "asdf qwer" }

      it "returns true when present" do
        answer.custom_class_present?("asdf").should be_true
        answer.custom_class_present?("qwer").should be_true
      end

      it "returns false when not present" do
        %w(asd qwe 1234 qwerty).each do |c|
          answer.custom_class_present?(c).should be_false
        end
      end

    end


  end

end
