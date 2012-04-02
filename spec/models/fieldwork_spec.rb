# == Schema Information
# Schema version: 20120321181032
#
# Table name: fieldworks
#
#  fieldwork_id  :string(36)      primary key
#  received_data :binary
#  created_at    :datetime
#  updated_at    :datetime
#  client_id     :string(255)
#  end_date      :date
#  start_date    :date
#  original_data :binary
#

require 'spec_helper'

describe Fieldwork do
  let(:id) { '81f474e2-c92b-4243-bee9-41c223abf873' }

  subject { FactoryGirl.build(:fieldwork) }

  describe '.for' do
    it 'retrieves a fieldwork set' do
      subject.save!

      Fieldwork.for(subject.id).should == subject
    end

    it "creates one if one doesn't exist" do
      fw = Fieldwork.for(id)

      fw.id.should == id
      fw.should_not be_new_record
    end
  end

  describe '.from_psc' do
    let(:params) do
      {
        :start_date => '2012-02-01',
        :end_date => '2012-03-01',
        :client_id => '123456789'
      }
    end

    describe 'return value' do
      let(:fieldwork) { Fieldwork.from_psc(params, stub, 'test') }

      before do
        NcsNavigator::Core::Psc::ScheduledActivityReport.stub!(
          :from_psc => NcsNavigator::Core::Psc::ScheduledActivityReport.new)
      end

      it 'is unpersisted' do
        fieldwork.should_not be_persisted
      end

      it 'contains the given client ID' do
        fieldwork.client_id.should == params[:client_id]
      end

      it 'contains the given start date' do
        fieldwork.start_date.should == Date.new(2012, 02, 01)
      end

      it 'contains the given end date' do
        fieldwork.end_date.should == Date.new(2012, 03, 01)
      end
    end
  end

  describe '#fieldwork_id' do
    it 'is the primary key' do
      Fieldwork.primary_key.should == 'fieldwork_id'
    end

    it 'is initially nil' do
      subject.fieldwork_id.should be_nil
    end

    it 'exists after creation' do
      subject.save!

      subject.fieldwork_id.should_not be_nil
    end

    it 'persists across updates' do
      subject.save!
      id = subject.fieldwork_id

      subject.received_data = '{}'
      subject.save

      subject.reload.fieldwork_id.should == id
    end

    it 'is not mass-assignable' do
      subject.attributes = { :fieldwork_id => id }

      subject.fieldwork_id.should be_nil
    end
  end

  describe '#start_date' do
    it 'is mass-assignable' do
      subject.attributes = { :start_date => '2012-01-01' }

      subject.start_date.should == Date.new(2012, 1, 1)
    end

    it 'is required' do
      subject.start_date = nil

      subject.should have(1).error_on(:start_date)
    end
  end

  describe '#end_date' do
    it 'is mass-assignable' do
      subject.attributes = { :end_date => '2012-01-01' }

      subject.end_date.should == Date.new(2012, 1, 1)
    end

    it 'is required' do
      subject.end_date = nil

      subject.should have(1).error_on(:end_date)
    end
  end

  describe '#client_id' do
    it 'is mass-assignable' do
      subject.attributes = { :client_id => 'DN6FQ12ZDKPJ' }

      subject.client_id.should == 'DN6FQ12ZDKPJ'
    end

    it 'is required' do
      subject.client_id = nil

      subject.should have(1).error_on(:client_id)
    end
  end

  describe 'before save' do
    describe 'if #report is not nil' do
      let(:report) { NcsNavigator::Core::Psc::ScheduledActivityReport.new }

      before do
        subject.report = report

        report.stub!(:contacts_as_json)
        report.stub!(:participants_as_json)
        report.stub!(:instrument_templates_as_json)
      end

      it "saves all report entities" do
        report.should_receive(:save_entities)

        subject.save
      end

      it "sets #original_data" do
        report.stub!(:save_entities => true)

        subject.save

        subject.original_data.should_not be_nil
      end

      describe 'if report entities cannot be saved' do
        it 'aborts the save' do
          report.stub!(:save_entities => false)

          lambda { subject.save! }.should raise_error(ActiveRecord::RecordNotSaved)
        end
      end

      describe 'the JSON in #original_data' do
        let(:json) { JSON.parse(subject.original_data) }

        before do
          report.stub!(:save_entities => true)

          report.should_receive(:contacts_as_json).and_return([])
          report.should_receive(:participants_as_json).and_return([])
          report.should_receive(:instrument_templates_as_json).and_return([])

          subject.save
        end

        it 'has a "contacts" key' do
          json.should have_key('contacts')
        end

        it 'has a "participants" key' do
          json.should have_key('participants')
        end

        it 'has an "instrument_templates" key' do
          json.should have_key('instrument_templates')
        end
      end
    end

    describe 'if #report is nil' do
      before do
        subject.report = nil
      end

      it 'does not modify #original_data' do
        subject.save

        subject.original_data.should be_nil
      end
    end
  end
end
