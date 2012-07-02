# -*- coding: utf-8 -*-
class RecordOfContactProcessor

  attr_accessor :filepath
  attr_accessor :uploaded_records
  attr_accessor :records_to_process
  attr_accessor :error_records

  def initialize(filepath)
    self.filepath = filepath
    raise ROCFileNotFoundException unless File.exists?(self.filepath)

    self.uploaded_records   = []
    self.records_to_process = []
    self.error_records      = []
    process_upload_file
  end
  
  def process
    self.records_to_process.each do |row|
      cl = ContactLink.new()
    end
  end

  def process_upload_file
    determine_records_to_process
    filter_invalid_records
  end
  private :process_upload_file

  def determine_records_to_process
    file = File.open(self.filepath)
    Rails.application.csv_impl.parse(file, :headers => true, :header_converters => :symbol) do |row|
      self.uploaded_records << row
    end
  end
  private :determine_records_to_process

  def filter_invalid_records
    self.uploaded_records.each do |row|
      if participant = Participant.where(:p_id => row[PARTICIPANT_ID]).first
        self.records_to_process << row
      else
        self.error_records << row
      end
    end
  end
  private :filter_invalid_records

end

class ROCFileNotFoundException < Exception; end

# INDICIES
PSU_ID                     = 0
CONTACT_DISPOSITION        = 1
CONTACT_TYPE               = 2
CONTACT_TYPE_OTHER         = 3
CONTACT_DATE               = 4
CONTACT_START_TIME         = 5
CONTACT_END_TIME           = 6
CONTACT_LANGUAGE           = 7
CONTACT_LANGUAGE_OTHER     = 8
CONTACT_INTERPRET          = 9
CONTACT_INTERPRET_OTHER    = 10
CONTACT_LOCATION           = 11
CONTACT_LOCATION_OTHER     = 12
CONTACT_PRIVATE            = 13
WHO_CONTACTED              = 14
CONTACT_COMMENT            = 15
PARTICIPANT_ID             = 16
EVENT_TYPE                 = 17
EVENT_TYPE_OTHER           = 18
EVENT_DISPOSITION          = 19
EVENT_DISPOSITION_CATEGORY = 20
EVENT_START_DATE           = 21
EVENT_START_TIME           = 22
EVENT_BREAKOFF             = 23
EVENT_COMMENT              = 24
STAFF_ID                   = 25
PERSON_ID                  = 26
PERSON_LAST_NAME           = 27
PERSON_FIRST_NAME          = 28
RELATIONSHIP               = 29
