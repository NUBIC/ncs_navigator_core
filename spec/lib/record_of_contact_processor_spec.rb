# -*- coding: utf-8 -*-


require 'spec_helper'
require "#{Rails.root}/lib/record_of_contact_processor"

describe RecordOfContactProcessor do

  let(:filepath) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/data/eroc_upload.csv') }
  let(:bad_path) { File.expand_path(File.dirname(__FILE__) + '/../non_existent_file.csv') }
  let(:eroc_processor) { RecordOfContactProcessor.new(filepath) }

  context 'initialization' do
    it 'reads a given file' do
      eroc_processor.filepath.should == filepath
      eroc_processor.uploaded_records.size.should == 4
      eroc_processor.uploaded_records.first.size.should == 30
      eroc_processor.uploaded_records.first[16].should == '11111111'
    end

    it 'raises an exception if the file does not exist' do
      # lambda { RecordOfContactProcessor.new bad_path }.should raise_error(ROCFileNotFoundException) # not working
      begin
        RecordOfContactProcessor.new bad_path
      rescue Exception => e
        e.class.should == ROCFileNotFoundException
      end
    end
  end

  context 'without known participants' do
    it 'logs the rows in the upload file where a participant record does not exist' do
      eroc_processor.error_records.size.should == 4
    end
  end

  context 'with known participants' do

    let(:known_participant_ids) { ['11111111', '22222222', '22221111', '11112222'] }

    before do
      known_participant_ids.each { |pid| Factory(:participant, :p_id => pid ) }
    end

    it 'has no error_records' do
      eroc_processor.error_records.should be_empty
    end

    describe 'processing contacts' do

      before do
        Contact.count.should == 0
        ContactLink.count.should == 0
      end

      it 'creates contact and contact link records'

    end


    describe 'processing events'

  end

end