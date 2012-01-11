# == Schema Information
# Schema version: 20111212224350
#
# Table name: events
#
#  id                              :integer         not null, primary key
#  psu_code                        :integer         not null
#  event_id                        :string(36)      not null
#  participant_id                  :integer
#  event_type_code                 :integer         not null
#  event_type_other                :string(255)
#  event_repeat_key                :integer
#  event_disposition               :integer
#  event_disposition_category_code :integer         not null
#  event_start_date                :date
#  event_start_time                :string(255)
#  event_end_date                  :date
#  event_end_time                  :string(255)
#  event_breakoff_code             :integer         not null
#  event_incentive_type_code       :integer         not null
#  event_incentive_cash            :decimal(12, 2)
#  event_incentive_noncash         :string(255)
#  event_comment                   :text
#  transaction_type                :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#

require 'spec_helper'

describe Event do

  it "should create a new instance given valid attributes" do
    e = Factory(:event)
    e.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:event_type) }
  it { should belong_to(:event_disposition_category) }
  it { should belong_to(:event_breakoff) }
  it { should belong_to(:event_incentive_type) }

  it { should have_many(:contact_links) }

  it "knows when it is 'closed'" do
    e = Factory(:event)
    e.should_not be_closed

    e.event_disposition = 510
    e.should be_closed
    e.should be_completed
  end

  context "surveys for the event" do

    it "knows it's Surveys" do
      event_type = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Pregnancy Screener")
      e = Factory(:event, :event_type => event_type)
      survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
      e.surveys.should == [survey]
    end
  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      e = Factory(:event)
      e.public_id.should_not be_nil
      e.event_id.should == e.public_id
      e.event_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Event)

      e = Event.new
      e.psu = Factory(:ncs_code)
      e.participant = Factory(:participant)
      e.save!

      obj = Event.first
      obj.event_type.local_code.should == -4
      obj.event_disposition_category.local_code.should == -4
      obj.event_breakoff.local_code.should == -4
      obj.event_incentive_type.local_code.should == -4
    end
  end

  context "human-readable attributes" do
    it "returns the event type display text for to_s" do
      e = Factory(:event)
      e.to_s.should == e.event_type.display_text
    end

    it "concatenates the start date and time for the event start" do
      e = Factory(:event)
      e.event_start.should == "N/A"
      e.event_start_time = "HH:MM"
      e.event_start_date = Date.parse('2011-01-01')
      e.event_start.should == "2011-01-01 HH:MM"
    end

    it "concatenates the end date and time for the event end" do
      e = Factory(:event)
      e.event_end.should == "N/A"
      e.event_end_date = Date.parse('2011-01-01')
      e.event_end_time = "HH:MM"
      e.event_end.should == "2011-01-01 HH:MM"
    end
  end

  context "mapping events to psc segments" do

    it "should determine the segment based on the event's event type" do
      [
        ["Ongoing Tracking of Dwelling Units", nil],
        ["Pregnancy Screener", "Pregnancy Screener"],
        ["Pre-Pregnancy Visit", "Pre-Pregnancy"],
        ["Pregnancy Visit #1 SAQ", "Pregnancy Visit 1"]
      ].each do |event_type_text, psc_segment|
        event_type = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => event_type_text)
        e = Factory(:event, :event_type => event_type)
        e.psc_segment_name.should == psc_segment
      end
    end

  end

  context "disposition" do

    describe "household enumeration" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 1, :display_text => "Household Enumeration Events")
      end

      it "knows if it is complete" do
        (540..545).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 546, 539].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end

    describe "pregnancy screener" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 2, :display_text => "Pregnancy Screening Events")
      end

      it "knows if it is complete" do
        (560..565).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 566, 559].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end

    describe "general study" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 3, :display_text => "General Study Visits (including CASI SAQs)")
      end

      it "knows if it is complete" do
        (560..562).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 563, 559].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end

    describe "mailed back saq" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 4, :display_text => "Mailed Back Self Administered Questionnaires")
      end

      it "knows if it is complete" do
        (550..556).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 549, 557].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end

    describe "telephone interview" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 5, :display_text => "Telephone Interview Events")
      end

      it "knows if it is complete" do
        (590..595).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 589, 596].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end

    describe "internet survey" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 6, :display_text => "Internet Survey Events")
      end

      it "knows if it is complete" do
        (540..546).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end

      it "knows if it is not complete" do
        [510, 515, 539, 547].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end

  end

  describe '.TYPE_ORDER' do
    it 'has no duplicates' do
      Event::TYPE_ORDER.uniq.size.should == Event::TYPE_ORDER.size
    end

    it 'contains integers' do
      Event::TYPE_ORDER.collect(&:class).uniq.should == [Fixnum]
    end

    # TODO: don't hard-code the count
    it 'has an item for every event type' do
      Event::TYPE_ORDER.size.should == 35
    end
  end

  context "auto-completing MDES data" do

    before(:each) do
      create_missing_in_error_ncs_codes(Event)

      @person = Factory(:person)
      @participant = Factory(:participant)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
      @participant.person = @person
      @ppg_fu = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Pregnancy Probability", :local_code => 7)
      @preg_screen = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Pregnancy Screener", :local_code => 29)
      @hh = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Household Enumeration", :local_code => 1)

      [
        [1, "Household Enumeration Events"],
        [2, "Pregnancy Screening Events"],
        [3, "General Study Visits (including CASI SAQs)"],
        [4, "Mailed Back Self Administered Questionnaires"],
        [5, "Telephone Interview Events"],
        [6, "Internet Survey Events"]
      ].each do |local_code, display_text|
        Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :display_text => display_text, :local_code => local_code)
      end

      @telephone = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Telephone', :local_code => 3)
      @mail      = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Mail', :local_code => 2)
      @in_person = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'In-Person', :local_code => 1)
      @txtmsg    = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Text Message', :local_code => 5)
      @website   = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Website', :local_code => 6)

      @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
      @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)

    end

    describe "the disposition category" do

      it "is first determined by the event type" do
        event = Event.create(:participant => @participant, :event_type => @preg_screen, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes
        event.save!
        event.event_disposition_category.local_code.should == 2

        event = Event.create(:participant => @participant, :event_type => @hh, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes
        event.save!
        event.event_disposition_category.local_code.should == 1
      end

      it "is next determined by the contact type" do
        # telephone
        contact = Factory(:contact, :contact_type => @telephone)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 5

        # mail
        contact = Factory(:contact, :contact_type => @mail)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 4

        # txt
        contact = Factory(:contact, :contact_type => @txtmsg)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 6

        # website
        contact = Factory(:contact, :contact_type => @website)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 6

        # in person
        contact = Factory(:contact, :contact_type => @in_person)
        event = Event.create(:participant => @participant, :event_type => @ppg_fu, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(contact)
        event.save!
        event.event_disposition_category.local_code.should == 3

      end

    end
    # = f.text_field :event_repeat_key
    # = render "shared/disposition_code", { :f => f, :code => :event_disposition }

    describe "the breakoff code" do

      it "should set the breakoff code to no if the reponse set has questions answered" do
        response_set = Factory(:response_set)
        response_set.stub!(:has_responses_in_each_section_with_questions?).and_return(true)
        event = Event.create(:participant => @participant, :event_type => @preg_screen, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(nil, response_set)
        event.save!
        event.event_breakoff.should == @n
      end


      it "should set the breakoff code to yes if the reponse set does not have questions answered in each section" do
        response_set = Factory(:response_set)
        response_set.stub!(:has_responses_in_each_section_with_questions?).and_return(false)
        event = Event.create(:participant => @participant, :event_type => @preg_screen, :psu_code => NcsNavigatorCore.psu_code)
        event.populate_post_survey_attributes(nil, response_set)
        event.save!
        event.event_breakoff.should == @y
      end

    end

    # = render "shared/ncs_code_select", { :f => f, :code => :event_incentive_type_code, :label_text => "Incentive Type" }
    # = f.text_field :event_incentive_cash
    # = f.text_field :event_incentive_noncash
    # = f.text_area :event_comment


  end
end
