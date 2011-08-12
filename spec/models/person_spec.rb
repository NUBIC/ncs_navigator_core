# == Schema Information
# Schema version: 20110805151543
#
# Table name: people
#
#  id                             :integer         not null, primary key
#  psu_code                       :string(36)      not null
#  person_id                      :binary          not null
#  prefix_code                    :integer         not null
#  first_name                     :string(30)
#  last_name                      :string(30)
#  middle_name                    :string(30)
#  maiden_name                    :string(30)
#  suffix_code                    :integer         not null
#  title                          :string(5)
#  sex_code                       :integer         not null
#  age                            :integer
#  age_range_code                 :integer         not null
#  person_dob                     :string(10)
#  person_dob_date                :date
#  deceased_code                  :integer         not null
#  ethnic_group_code              :integer         not null
#  language_code                  :integer         not null
#  language_other                 :string(255)
#  marital_status_code            :integer         not null
#  marital_status_other           :string(255)
#  preferred_contact_method_code  :integer         not null
#  preferred_contact_method_other :string(255)
#  planned_move_code              :integer         not null
#  move_info_code                 :integer         not null
#  when_move_code                 :integer         not null
#  date_move_date                 :date
#  date_move                      :string(7)
#  p_tracing_code                 :integer         not null
#  p_info_source_code             :integer         not null
#  p_info_source_other            :string(255)
#  p_info_date                    :date
#  p_info_update                  :date
#  person_comment                 :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#  being_processed                :boolean
#

require 'spec_helper'

describe Person do

  it "creates a new instance given valid attributes" do
    pers = Factory(:person)
    pers.should_not be_nil
  end
  
  it "describes itself" do
    pers = Factory(:person)
    name = "#{pers.first_name} #{pers.last_name}"
    pers.to_s.should == name
    pers.name.should == name
    pers.full_name.should == name
  end

  it { should belong_to(:psu) }
  it { should belong_to(:prefix) }
  it { should belong_to(:suffix) }
  it { should belong_to(:sex) }
  it { should belong_to(:age_range) }
  it { should belong_to(:deceased) }
  it { should belong_to(:ethnic_group) }
  it { should belong_to(:language) }
  it { should belong_to(:marital_status) }
  it { should belong_to(:preferred_contact_method) }
  it { should belong_to(:planned_move) }
  it { should belong_to(:move_info) }
  it { should belong_to(:when_move) }
  it { should belong_to(:p_tracing) }
  it { should belong_to(:p_info_source) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }

  it { should have_one(:participant) }
  it { should have_many(:response_sets) }
  it { should have_many(:contact_links) }
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      pers = Factory(:person)
      pers.public_id.should_not be_nil
      pers.person_id.should == pers.public_id
      pers.person_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Person)
      
      pers = Person.new
      pers.psu = Factory(:ncs_code)
      pers.first_name = "John"
      pers.last_name = "Doe"
      pers.save!
    
      obj = Person.find(pers.id)
      obj.prefix.local_code.should == -4
      obj.suffix.local_code.should == -4
      obj.sex.local_code.should == -4
      obj.age_range.local_code.should == -4
      obj.deceased.local_code.should == -4
      obj.ethnic_group.local_code.should == -4
      obj.language.local_code.should == -4
      obj.marital_status.local_code.should == -4
      obj.preferred_contact_method.local_code.should == -4
      obj.planned_move.local_code.should == -4
      obj.move_info.local_code.should == -4
      obj.when_move.local_code.should == -4
      obj.p_tracing.local_code.should == -4
      obj.p_info_source.local_code.should == -4
    end
  end
  
  context "mdes date formatting" do
    
    it "sets the corresponding date field with the user entered date" do
      dob = Date.today
      pers = Factory(:person)
      pers.person_dob_date = dob
      pers.save!
      pers = Person.last
      pers.person_dob.should == Date.today.strftime('%Y-%m-%d')
    end
    
    it "sets the person_dob if the person has refused to give the information" do
      pers = Factory(:person)
      pers.person_dob_modifier = "refused"
      pers.save!
      
      pers = Person.last
      pers.person_dob.should == '9111-91-91'
    end
    
    it "sets the person_dob if the person said the information is unknown" do
      pers = Factory(:person)
      pers.person_dob_modifier = "unknown"
      pers.save!
      
      pers = Person.last
      pers.person_dob.should == '9666-96-96'
    end
    
    it "sets the corresponding date field with the user entered date properly formatted" do
      move_date = Date.today
      pers = Factory(:person)
      pers.date_move_date = move_date
      pers.save!
      pers = Person.last
      pers.date_move.should == Date.today.strftime('%Y-%m')
    end
    
    it "sets the date_move if the person said the information is not_applicable" do
      pers = Factory(:person)
      pers.date_move_modifier = "not_applicable"
      pers.save!
      
      pers = Person.last
      pers.date_move.should == '9777-97'
    end
  end
  
  context "determining date" do
    
    it "returns the person's age" do
      pers = Factory(:person, :person_dob_date => 10.years.ago)
      pers.age.should == 10
    end
    
    it "does not blowup on leap year" do
      dob = Date.parse('02/29/1992')
      pers = Factory(:person, :person_dob_date => dob)
      (pers.age > 18).should be_true
    end
    
    it "does not return anything if person dob is unknown" do
      pers = Factory(:person)
      pers.person_dob_modifier = "unknown"
      pers.save!
      
      Person.last.age.should be_nil
    end
    
    it "does not return anything if person dob is refused" do
      pers = Factory(:person)
      pers.person_dob_modifier = "refused"
      pers.save!
      
      Person.last.age.should be_nil
    end
    
    it "handles a string date" do
      dob = 10.years.ago
      pers = Factory(:person, :person_dob_date => nil, :person_dob => dob.strftime('%Y-%m-%d'))
      pers.age.should == 10
    end
    
  end

  context "with events" do
    
    describe "a person who is not a participant" do
    
      it "knows the upcoming applicable events" do
        pers = Factory(:person)
        pers.upcoming_events.should_not be_empty
      
        pers.should_not be_participant
        pers.upcoming_events.should == ["Pregnancy Screener"]
      end
    end
    
    describe "a participant who is pregnant - PPG 1" do
    
      it "knows the upcoming applicable events" do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
        participant = Factory(:participant)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
        participant.upcoming_events.should_not be_empty
      
        participant.person.should be_participant
        participant.upcoming_events.should == ["Pregnancy Visit 1"]
      end
    end
    
    describe "a participant who is not pregnant but actively trying - PPG 2" do
      
      it "knows the upcoming applicable events" do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2)
        participant = Factory(:participant)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
        participant.upcoming_events.should_not be_empty
    
        participant.person.should be_participant
        participant.upcoming_events.should == ["Pre-Pregnancy"]
      end
    end
    
    describe "a participant who has had a recent pregnancy loss - PPG 3" do
      
      it "knows the upcoming applicable events" do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3)
        participant = Factory(:participant)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
        participant.upcoming_events.should_not be_empty
    
        participant.person.should be_participant
        participant.upcoming_events.should == ["Pregnancy Probability"]
      end
    end
    
    describe "a participant who is not pregnant and not trying - PPG 4" do
      
      it "knows the upcoming applicable events" do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 4: Other Probability – Not Pregnancy and not Trying", :local_code => 4)
        participant = Factory(:participant)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
        participant.upcoming_events.should_not be_empty
    
        participant.person.should be_participant
        participant.upcoming_events.should == ["Pregnancy Probability"]
      end
    end
    
  end

  
  context "with instruments" do
        
    describe "a participant who is in ppg1 - Currently Pregnant and Eligible" do
      
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant, :person => person) }

      let(:pv1survey) { Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-p2-v2-0") }
      let(:presurvey) { Factory(:survey, :title => "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1", :access_code => "ins-que-prepreg-int-ehpbhi-p2-v1-1") }

      let(:status1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
      let(:status2) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }

      before(:each) do
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)
      end
    
      it "creates a response set for the instrument" do

        section   = Factory(:survey_section, :survey => pv1survey)
        question  = Factory(:question, :survey_section => section, :data_export_identifier => "name")
        answer    = Factory(:answer, :question => question)

        ResponseSet.where(:user_id => person.id).should be_empty
      
        person.start_instrument(participant.person.next_survey)
      
        rs = ResponseSet.where(:user_id => person.id).first
        rs.should_not be_nil
        rs.responses.should_not be_empty
        rs.responses.first.string_value.should == person.name
      end

    end
    
  end

end
