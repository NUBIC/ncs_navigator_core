require 'spec_helper'

describe Fieldwork do
  let(:id) { '81f474e2-c92b-4243-bee9-41c223abf873' }

  describe '.for' do
    it 'retrieves a fieldwork set' do
      fw = Fieldwork.create!

      Fieldwork.for(fw.id).should == fw
    end

    it "creates one if one doesn't exist" do
      fw = Fieldwork.for(id)

      fw.id.should == id
    end
  end

  describe '#fieldwork_id' do
    it 'is the primary key' do
      Fieldwork.primary_key.should == 'fieldwork_id'
    end

    it 'exists after creation' do
      f = Fieldwork.create

      f.fieldwork_id.should_not be_nil
    end

    it 'persists across updates' do
      f = Fieldwork.create
      id = f.fieldwork_id

      f.received_data = '{}'
      f.save

      f.reload.fieldwork_id.should == id
    end
  end
end
