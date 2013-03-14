# -*- coding: utf-8 -*-
require 'spec_helper'

describe ContactLinksHelper do
  let(:contact) { Factory(:contact) }
  let(:contact_link) { Factory(:contact_link, :contact => contact, :event => event) }
  let(:survey) { Factory(:survey) }

  describe '#instrument_exists_for_survey?' do
    let(:event) { Factory(:event) }
    it "is false when survey is nil" do
      helper.instrument_exists_for_survey?(contact_link, nil).should be_false
    end

    it "is false when event has no instrument_survey_titles" do
      event.stub!(:instrument_survey_titles => [])
      helper.instrument_exists_for_survey?(contact_link, survey).should be_false
    end

    it "is true when event instrument_survey_titles includes the survey title" do
      event.stub!(:instrument_survey_titles => [survey.title])
      helper.instrument_exists_for_survey?(contact_link, survey).should be_true
    end

    it "is false when event instrument_survey_titles does not includes the survey title" do
      event.stub!(:instrument_survey_titles => ["not the survey title"])
      helper.instrument_exists_for_survey?(contact_link, survey).should be_false
    end
  end

  describe "#show_continue_action" do
    let(:participant) { Factory(:participant) }
    let(:person) { Factory(:person) }
    let(:event) { Factory(:event, :event_type => et) }

    context "with a continuable event" do
      let(:et) { NcsCode.pregnancy_screener }

      context "with a participant in the study" do
        it "is true" do
          participant.stub!(:in_study? => true)
          helper.show_continue_action(person, contact_link, event, participant).should be_true
        end
      end

      context "with a participant not in the study" do
        it "is false" do
          participant.stub!(:in_study? => false)
          helper.show_continue_action(person, contact_link, event, participant).should be_false
        end
      end
    end

    context "without a continuable event" do
      let(:et) { NcsCode.low_intensity_data_collection }

      context "with a participant in the study" do
        it "is false" do
          participant.stub!(:in_study? => true)
          helper.show_continue_action(person, contact_link, event, participant).should be_false
        end
      end
    end

  end
end