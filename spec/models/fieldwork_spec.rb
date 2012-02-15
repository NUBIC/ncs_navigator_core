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
end
