# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: fieldworks
#
#  client_id           :string(255)
#  created_at          :datetime
#  end_date            :date
#  fieldwork_id        :string(36)
#  generation_log      :text
#  id                  :integer          not null, primary key
#  latest_merge_id     :integer
#  latest_merge_status :string(255)
#  original_data       :binary
#  staff_id            :string(255)
#  start_date          :date
#  updated_at          :datetime
#



require 'spec_helper'

describe Fieldwork do
  let(:id) { '81f474e2-c92b-4243-bee9-41c223abf873' }

  subject { FactoryGirl.build(:fieldwork) }

  it { should have_many(:merges) }

  describe '.for' do
    describe "if the given ID doesn't exist" do
      it "creates one" do
        fw = Fieldwork.for(id, 'test')

        fw.fieldwork_id.should == id
        fw.should_not be_new_record
      end

      it 'sets #staff_id' do
        fw = Fieldwork.for(id, 'test')

        Fieldwork.find(fw.id).staff_id.should == 'test'
      end
    end

    describe "if the given ID exists" do
      before do
        subject.fieldwork_id = id
        subject.save!
      end

      it 'retrieves a fieldwork set' do
        Fieldwork.for(id, 'test').should == subject
      end

      it 'sets #staff_id' do
        fw = Fieldwork.for(id, 'test')

        Fieldwork.find(fw.id).staff_id.should == 'test'
      end
    end
  end

  describe '.from_psc' do
    let(:start_date) { '2012-02-01' }
    let(:end_date) { '2012-03-01' }
    let(:client_id) { '1234567890' }

    let(:fieldwork) { Fieldwork.from_psc(start_date, end_date, client_id, stub, 'test', 'test') }

    before do
      Field::ScheduledActivityReport.stub!(:from_psc => Field::ScheduledActivityReport.new)
    end

    it 'sets #staff_id' do
      fieldwork.staff_id.should == 'test'
    end

    it 'logs to #generation_log' do
      fieldwork.generation_log.should_not be_empty
    end

    describe 'return value' do
      it 'is unpersisted' do
        fieldwork.should_not be_persisted
      end

      it 'contains the given client ID' do
        fieldwork.client_id.should == client_id
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
      subject.touch

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

  describe '#latest_proposed_data' do
    before do
      subject.save!
    end

    it 'returns #proposed_data on the latest associated Merge' do
      m1 = subject.merges.create!(:proposed_data => '{"foo":null}', :created_at => Time.now + 10, :client_id => 'foo', :staff_id => 'bar')
      m2 = subject.merges.create!(:proposed_data => '{"bar":null}', :created_at => Time.now - 10, :client_id => 'foo', :staff_id => 'bar')

      subject.latest_proposed_data.should == '{"foo":null}'
    end

    it 'returns nil if there are no merges' do
      subject.latest_proposed_data.should be_nil
    end
  end

  describe 'before save' do
    describe 'if #report is not nil' do
      let(:report) { Field::ScheduledActivityReport.new }

      before do
        subject.report = report
      end

      it "saves all report entities" do
        report.should_receive(:save_models)

        subject.save
      end

      it "sets #original_data" do
        report.stub!(:save_models => true)

        subject.save

        subject.original_data.should_not be_nil
      end

      describe 'if report entities cannot be saved' do
        it 'aborts the save' do
          report.stub!(:save_models => false)

          lambda { subject.save! }.should raise_error(ActiveRecord::RecordNotSaved)
        end
      end

      describe 'the JSON in #original_data' do
        let(:json) { JSON.parse(subject.original_data) }

        before do
          report.stub!(:save_models => true)

          subject.save
        end

        it 'has a "contacts" key' do
          json.should have_key('contacts')
        end

        it 'has a "participants" key' do
          json.should have_key('participants')
        end

        it 'has an "instrument_plans" key' do
          json.should have_key('instrument_plans')
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

