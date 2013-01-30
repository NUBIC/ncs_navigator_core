# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130129202515
#
# Table name: fieldworks
#
#  client_id           :string(255)
#  contact_links       :text
#  contacts            :text
#  created_at          :datetime
#  end_date            :date
#  events              :text
#  fieldwork_id        :string(36)
#  generated_for       :string(255)
#  generation_log      :text
#  id                  :integer          not null, primary key
#  instrument_plans    :text
#  instruments         :text
#  latest_merge_id     :integer
#  latest_merge_status :string(255)
#  original_data       :binary
#  people              :text
#  staff_id            :string(255)
#  start_date          :date
#  surveys             :text
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
      m1 = subject.merges.create!(:proposed_data => '{"foo":null}', :created_at => Time.now + 10, :client_id => 'foo', :staff_id => 'bar', :username => 'baz')
      m2 = subject.merges.create!(:proposed_data => '{"bar":null}', :created_at => Time.now - 10, :client_id => 'foo', :staff_id => 'bar', :username => 'baz')

      subject.latest_proposed_data.should == '{"foo":null}'
    end

    it 'returns nil if there are no merges' do
      subject.latest_proposed_data.should be_nil
    end
  end

  describe '#collections_changed?' do
    it 'returns false if no collections changed' do
      subject.collections_changed?.should be_false
    end

    Fieldwork.collections.keys.each do |k|
      describe "if ##{k} changed" do
        it 'returns true' do
          subject.send("#{k}=", [])

          subject.collections_changed?.should be_true
        end
      end
    end
  end

  describe 'before save' do
    before do
      subject.logger = ::Logger.new(nil)
    end

    describe 'if collections were changed' do
      before do
        subject.stub!(:collections_changed? => true)
      end

      it 'builds models from those collections' do
        subject.should_receive(:reify_models)

        subject.save
      end

      it 'saves built models' do
        subject.should_receive(:save_models)

        subject.save
      end

      it 'sets #original_data' do
        subject.save

        subject.original_data.should_not be_nil
      end

      describe 'if built models cannot be saved' do
        before do
          subject.stub!(:save_models => false)
        end

        it 'aborts the save' do
          lambda { subject.save! }.should raise_error(ActiveRecord::RecordNotSaved)
        end
      end
    end

    describe 'if collections were not changed' do
      before do
        subject.stub!(:collections_changed? => false)
      end

      it 'does not modify #original_data' do
        subject.save

        subject.original_data.should be_nil
      end
    end
  end
end
