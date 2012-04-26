# -*- coding: utf-8 -*-
require 'spec_helper'

describe Reporting::CaseStatusReport do

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "user", :cas_proxy_ticket => "PT-cas-ticket")
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
    @state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "ILLINOIS", :local_code => 14)
    @pv1 = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "PV1", :local_code => 13)
    @loi = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Lo I Quex", :local_code => 33)
  end

  let(:subject) { PatientStudyCalendar.new(@user) }

  let(:ppg1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
  let(:ppg2) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }

  let(:scheduled_study_segment_identifier_1) { 'b3e4b432-b4f6-4b27-ad6b-6a37e17da5ab' } # LUCY
  let(:scheduled_study_segment_identifier_2) { 'fdbf8c20-7805-4d7f-b82c-ee3624641509' } # HENRIETTA
  let(:reporter) { Reporting::CaseStatusReport.new(subject, { :start_date => '2012-02-01', :end_date => '2012-02-07' }) }

  it "uses the scheduled activities report from psc to get event identifiers" do

    VCR.use_cassette('psc/case_status_report') do
      ids = reporter.scheduled_study_segment_identifiers
      ids.size.should == 2
      ids.should include scheduled_study_segment_identifier_1
      ids.should include scheduled_study_segment_identifier_2
    end

  end

  it "handles an empty response from psc" do
    subject.stub!(:scheduled_activities_report).and_return Hash.new
    reporter.scheduled_study_segment_identifiers.should == []
  end

  context "creating a status report for a given period" do

    before(:each) do
      create_missing_in_error_ncs_codes(Person)
      create_missing_in_error_ncs_codes(Participant)
      create_missing_in_error_ncs_codes(Address)
      create_missing_in_error_ncs_codes(Telephone)
      create_missing_in_error_ncs_codes(Event)
      create_missing_in_error_ncs_codes(Contact)
      create_missing_in_error_ncs_codes(ContactLink)

      @per1 = Factory(:person, :first_name => 'LUCY', :last_name => 'VANPELT')
      Factory(:address, :person => @per1, :state => @state, :address_one => "1 Peanut Drive")
      Factory(:telephone, :person => @per1, :phone_nbr => "3125551212")

      @per2 = Factory(:person, :first_name => 'HENRIETTA', :last_name => 'BROWN')
      Factory(:address, :person => @per2, :state => @state, :address_one => "2 Main St")
      Factory(:telephone, :person => @per2, :phone_nbr => "3125559999")

      @p1 = Factory(:participant, :p_id => 'p1')
      @p1.person = @per1
      @p1.save!

      @p2 = Factory(:participant, :p_id => 'p2')
      @p2.person = @per2
      @p2.save!

      @e1 = Factory(:event, :participant => @p1, :event_type => @pv1, :scheduled_study_segment_identifier => scheduled_study_segment_identifier_1)
      @e2 = Factory(:event, :participant => @p2, :event_type => @loi, :scheduled_study_segment_identifier => scheduled_study_segment_identifier_2)
    end

    it "gets data for all scheduled case statuses" do
      VCR.use_cassette('psc/case_status_report') do

        case_statuses = reporter.case_statuses
        case_statuses.size.should == 2

        cs1 = case_statuses.first
        cs1.q_first_name.should == @per1.first_name
        cs1.q_phone.should == @per1.telephones.first.phone_nbr

        cs2 = case_statuses.last
        cs2.q_last_name.should == @per2.last_name
        cs2.q_address_one.should == @per2.addresses.first.address_one
      end
    end

    it "gets the last contact for those participants who have scheduled events" do
      VCR.use_cassette('psc/case_status_report') do
        c1 = Factory(:contact, :contact_date_date => 1.day.ago)
        l1 = Factory(:contact_link, :contact => c1, :person => @per1, :event => @e1)
        c2 = Factory(:contact, :contact_date_date => 1.week.ago)
        l2 = Factory(:contact_link, :contact => c2, :person => @per2, :event => @e2)

        p_ids = reporter.case_statuses.collect { |c| c.q_id }

        contacts = reporter.last_contacts(p_ids)
        contacts.size.should == 2
        contacts.keys.should include @p1.id
        contacts.keys.should include @p2.id
        contacts[@p1.id].contact_date.should == c1.contact_date
        contacts[@p2.id].contact_date.should == c2.contact_date
      end
    end

    it "gets the current ppg_status for those participants who have scheduled events" do
      VCR.use_cassette('psc/case_status_report') do

        Factory(:ppg_status_history, :participant => @p1, :ppg_status => ppg1, :ppg_status_date => 1.day.ago.to_date.to_s(:db))
        Factory(:ppg_status_history, :participant => @p2, :ppg_status => ppg2, :ppg_status_date => 1.week.ago.to_date.to_s(:db))

        p_ids = reporter.case_statuses.collect { |c| c.q_id }

        ppgs = reporter.ppg_statuses(p_ids)
        ppgs.size.should == 2
        ppgs.keys.should include @p1.id
        ppgs.keys.should include @p2.id
        ppgs[@p1.id].ppg_status.should == ppg1
        ppgs[@p2.id].ppg_status.should == ppg2
      end
    end

  end

end