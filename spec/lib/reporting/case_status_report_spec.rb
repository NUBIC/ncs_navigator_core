# -*- coding: utf-8 -*-

require 'spec_helper'

describe Reporting::CaseStatusReport do

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "user", :cas_proxy_ticket => "PT-cas-ticket")
    @state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
    @pv1 = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 13)
    @loi = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33)
  end

  let(:subject) { PatientStudyCalendar.new(@user) }

  let(:ppg1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1) }
  let(:ppg2) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2) }

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

  describe "#associate_scheduled_study_segment_ids_with_netids" do
    before(:each) do
      psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
      @uri  = psc_config["uri"]
      @user = mock(:username => "user", :cas_proxy_ticket => "PT-cas-ticket")
    end

    let(:subject) { PatientStudyCalendar.new(@user) }

    let(:reporter) { Reporting::CaseStatusReport.new(subject, { :start_date => '2012-02-01', :end_date => '2012-02-07' }) }


    it "associates scheduled_study_segment_ids with netids from the rows section of a scheduled activity report from PSC" do
      reporter.associate_scheduled_study_segment_ids_with_netids(sample_rows).should == {"0a968622-0251-4167-89c4-8ea8a6cbe62d"=>"sgp658",
                                                                                         "34bda70c-a060-48d3-9bbd-726f8994a90f"=>"sgp658",
                                                                                         "b0b0544b-6757-4dbb-9bc7-f85dbaf1f498"=>"sgp658"}
    end

  end

  def sample_rows
    [{"grid_id"=>"7b076342-1091-46ce-9445-26af0741d83e", "activity_name"=>"Pregnancy Screener Interview",
      "activity_type"=>"Instrument", "activity_status"=>"Scheduled", "scheduled_date"=>"2013-04-01",
      "last_change_reason"=>"Initialized from template", "ideal_date"=>"2013-04-01",
      "labels"=> ["event:pregnancy_screener",
                  "instrument:2.0:ins_que_pregscreen_int_hili_p2_v2.0",
                  "instrument:2.1:ins_que_pregscreen_int_hili_m2.1_v2.1",
                  "instrument:2.2:ins_que_pregscreen_int_hili_m2.1_v2.1",
                  "instrument:3.0:ins_que_pregscreen_int_hili_m2.1_v2.1",
                  "instrument:3.1:ins_que_pregscreen_int_hili_m2.1_v2.1",
                  "instrument:3.2:ins_que_pregscreen_int_hili_m2.1_v2.1",
                  "order:01_01"],

      "scheduled_study_segment"=>{"grid_id"=>"0a968622-0251-4167-89c4-8ea8a6cbe62d",
                                  "start_date"=>"2013-04-01",
                                  "start_day"=>1},
      "subject"=>{"name"=>"z3fa-d9dh-dbsw",
                  "person_id"=>"z3fa-d9dh-dbsw",
                  "grid_id"=>"802bfe59-cd22-4cfb-ac13-31a449b34187"},
      "responsible_user"=>"sgp658",
      "study"=>"NCS Hi-Lo",
      "site"=>"STEVES SITE"},

      {"grid_id"=>"56c71a5b-a00a-452b-8dd9-cdd3324dabfc", "activity_name"=>"Pregnancy Probability Group Follow-Up Interview",
       "activity_type"=>"Instrument", "activity_status"=>"Scheduled", "scheduled_date"=>"2013-04-02",
       "last_change_reason"=>"Initialized from template", "ideal_date"=>"2013-04-02",
       "labels"=>["event:pregnancy_probability",
                  "instrument:2.0:ins_que_ppgfollup_int_ehpbhili_p2_v1.2",
                  "instrument:2.1:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                  "instrument:2.2:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                  "instrument:3.0:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                  "instrument:3.1:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                  "instrument:3.2:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                  "order:01_01",
                  "participant_type:mother"],
        "scheduled_study_segment"=>{"grid_id"=>"34bda70c-a060-48d3-9bbd-726f8994a90f",
                                    "start_date"=>"2013-04-02",
                                    "start_day"=>1},
        "subject"=>{"name"=>"tzzz-649b-5zhe",
                    "person_id"=>"tzzz-649b-5zhe",
                    "grid_id"=>"6032b3bd-e0e5-41e8-a569-ba63a1201a7f"},
        "responsible_user"=>"sgp658",
        "study"=>"NCS Hi-Lo",
        "site"=>"STEVES SITE"},

        {"grid_id"=>"912b653a-e4a4-434b-97f0-91d02dc25830", "activity_name"=>"Pregnancy Probability Group Follow-Up SAQ",
         "activity_type"=>"Instrument", "activity_status"=>"Scheduled", "scheduled_date"=>"2013-04-02",
         "last_change_reason"=>"Initialized from template", "ideal_date"=>"2013-04-02",
         "labels"=>["event:pregnancy_probability",
                    "instrument:2.0:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                    "instrument:2.1:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                    "instrument:2.2:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                    "instrument:3.0:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                    "instrument:3.1:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                    "instrument:3.2:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                    "order:02_01",
                    "participant_type:mother"],
          "scheduled_study_segment"=>{"grid_id"=>"34bda70c-a060-48d3-9bbd-726f8994a90f",
                                      "start_date"=>"2013-04-02",
                                      "start_day"=>1},
          "subject"=>{"name"=>"tzzz-649b-5zhe",
                      "person_id"=>"tzzz-649b-5zhe",
                      "grid_id"=>"6032b3bd-e0e5-41e8-a569-ba63a1201a7f"},
          "responsible_user"=>"sgp658",
          "study"=>"NCS Hi-Lo",
          "site"=>"STEVES SITE"},

          {"grid_id"=>"083ed9fa-efae-453f-914b-967caffda84a", "activity_name"=>"Pregnancy Probability Group Follow-Up Interview",
           "activity_type"=>"Instrument", "activity_status"=>"Scheduled", "scheduled_date"=>"2013-04-04",
           "last_change_reason"=>"Initialized from template", "ideal_date"=>"2013-04-04",
           "labels"=>["event:pregnancy_probability",
                      "instrument:2.0:ins_que_ppgfollup_int_ehpbhili_p2_v1.2",
                      "instrument:2.1:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                      "instrument:2.2:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                      "instrument:3.0:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                      "instrument:3.1:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                      "instrument:3.2:ins_que_ppgfollup_int_ehpbhili_m2.1_v1.3",
                      "order:01_01", "participant_type:mother"],
            "scheduled_study_segment"=>{"grid_id"=>"b0b0544b-6757-4dbb-9bc7-f85dbaf1f498",
                                        "start_date"=>"2013-04-04",
                                        "start_day"=>1},
            "subject"=>{"name"=>"yhyf-37w6-e59w",
                        "person_id"=>"yhyf-37w6-e59w",
                        "grid_id"=>"0a042406-c4e2-4ee3-81fd-68b4d8bba994"},
            "responsible_user"=>"sgp658",
            "study"=>"NCS Hi-Lo",
            "site"=>"STEVES SITE"},

            {"grid_id"=>"567cb7bf-112e-4d08-aa92-692f70d8d847", "activity_name"=>"Pregnancy Probability Group Follow-Up SAQ",
             "activity_type"=>"Instrument", "activity_status"=>"Scheduled", "scheduled_date"=>"2013-04-04",
             "last_change_reason"=>"Initialized from template", "ideal_date"=>"2013-04-04",
             "labels"=>["event:pregnancy_probability",
                        "instrument:2.0:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                        "instrument:2.1:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                        "instrument:2.2:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                        "instrument:3.0:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                        "instrument:3.1:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                        "instrument:3.2:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1",
                        "order:02_01",
                        "participant_type:mother"],
              "scheduled_study_segment"=>{"grid_id"=>"b0b0544b-6757-4dbb-9bc7-f85dbaf1f498",
                                          "start_date"=>"2013-04-04",
                                          "start_day"=>1},
              "subject"=>{"name"=>"yhyf-37w6-e59w",
                          "person_id"=>"yhyf-37w6-e59w",
                          "grid_id"=>"0a042406-c4e2-4ee3-81fd-68b4d8bba994"},
              "responsible_user"=>"sgp658",
              "study"=>"NCS Hi-Lo",
              "site"=>"STEVES SITE"}]
  end
end
