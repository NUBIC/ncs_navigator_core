# -*- coding: utf-8 -*-

module Reporting
  class CaseStatusReport

    REPORT_HEADERS = [
      "Staff NetID",
      "Participant ID",
      "First Name",
      "Last Name",
      "Next Event Date",
      "Event Time",
      "Event Name",
      "Last Contact Date",
      "Last Contact Start Time",
      "Last Contact End Time",
      "Contact Comments",
      "PPG Status",
      "PPG Status Description",
      "Language",
      "Last Contact Disposition",
      "Last Contact Type",
      "Phone Number",
      "Address One",
      "Address Two",
      "City",
      "State",
      "Zip",
      "TSU Identifier",
      "SSU Identifier",
      "HI/LO Arm"
    ]

    attr_accessor :psc
    attr_accessor :options

    ##
    # Creates a new instance of the CaseStatusReport
    # @param[PatientStudyCalendar]
    # @param[Hash] - {:start_date => x, :end_date => y}
    def initialize(psc, options = {})
      self.psc = psc
      defaults = {
        :start_date => Date.today.to_s(:db),
        :end_date   => 1.week.from_now.to_date.to_s(:db)
      }
      self.options = defaults.merge(options)
    end

    ##
    # Use Patient Study Calendar to get the scheduled activities for the given dates
    # Default dates to the upcoming week
    # @return [Array<String>] - scheduled_study_segment grid_ids
    def scheduled_study_segment_identifiers
      scheduled_study_segment_ids = []
      if rpt = psc.scheduled_activities_report(options)
        if rows = rpt["rows"]
          rows.each do |row|
            if row["scheduled_study_segment"] && matches_date_range(options, row)
              scheduled_study_segment_ids << row["scheduled_study_segment"]["grid_id"]
            end
          end
        end
      end
      scheduled_study_segment_ids.uniq
    end

    ##
    # Check if the ["scheduled_study_segment"]["start_date"]
    # is between the options[:start_date] and [:end_date]
    # @param options [Hash<Symbol,String>]
    # @param row [Hash<Hash(String,String)>]
    # @return [Boolean]
    def matches_date_range(options, row)
      begin
        date = row["scheduled_study_segment"]["start_date"]
        date >= options[:start_date] && date <= options[:end_date]
      rescue
        # if date cannot be parsed return false
        false
      end
    end

    # @todo move this to the model along with PeopleHelper
    # @ todo consider ranks, currently only primary is considered i.e.
    #   and a.address_rank_code = 1
    def top_addresses_sql
      sql= <<-SQL
        SELECT DISTINCT ON (person_id) person_id, address_type_code as address_type
          FROM addresses
          ORDER BY person_id,
                   position(CAST(address_type_code AS char) in '#{PeopleHelper::TYPE_ORDER.to_s}'),
                   updated_at
      SQL
    end

    # @todo move this to the model along with PeopleHelper
    # @ todo consider ranks, currently only primary is considered i.e.
    #   and t.phone_rank_code = 1
    def top_phones_sql
      sql= <<-SQL
        SELECT DISTINCT ON (person_id) person_id, phone_type_code as phone_type
          FROM telephones
          ORDER BY person_id,
                   position(CAST(phone_type_code AS char) in '#{PeopleHelper::TYPE_ORDER.to_s}'),
                   updated_at
      SQL
    end

    ##
    # Runs a query to get the Participant data for those with scheduled activities
    # in the given date range
    # @return [Array<Participant>]
    def case_statuses
      ids = scheduled_study_segment_identifiers.map {|i| "'#{i}'" }.join(',')
      return [] if ids.blank?
      sql = <<-SQL
        with addrsql as
        (#{top_addresses_sql}
        )
        ,phonesql as
        (#{top_phones_sql}
        )
        select part.id as q_id, part.p_id, part.high_intensity as q_high_intensity, pers.first_name as q_first_name, pers.last_name as q_last_name,
         max(e.event_start_date) as q_event_date, event_code.display_text as q_event_name, e.event_start_time as q_event_time,
         e.scheduled_study_segment_identifier as q_event_identifier,
         t.phone_nbr as q_phone,
         a.address_one as q_address_one, a.address_two as q_address_two, a.city as q_city,
         du.ssu_id as q_ssu_id, du.tsu_id as q_tsu_id,
         state_code.display_text as q_state, a.zip as q_zip
         from participants part
         left outer join participant_person_links ppl on ppl.participant_id = part.id
         left outer join people pers on pers.id = ppl.person_id
         left outer join events e on e.participant_id = part.id
         left outer join telephones t on t.person_id = pers.id
         left outer join addresses a on a.person_id = pers.id
         left outer join dwelling_units du on du.id = a.dwelling_unit_id
         left outer join ncs_codes state_code on state_code.local_code = a.state_code
         left outer join ncs_codes event_code on event_code.local_code = e.event_type_code
         left outer join addrsql on pers.id = addrsql.person_id
         left outer join phonesql on pers.id = phonesql.person_id
         where ppl.relationship_code = 1
         and e.scheduled_study_segment_identifier in (#{ids})
         and state_code.list_name = 'STATE_CL1'
         and event_code.list_name = 'EVENT_TYPE_CL1'
         and a.address_rank_code = 1
         and a.address_type_code = addrsql.address_type
         and t.phone_rank_code = 1
         and t.phone_type_code = phonesql.phone_type
         group by part.id, part.p_id, part.high_intensity, pers.first_name, pers.last_name,
         e.event_start_date, e.event_start_time, event_code.display_text, e.scheduled_study_segment_identifier,
         t.phone_nbr, a.address_one, a.address_two, a.city,  state_code.display_text, a.zip,
         du.ssu_id, du.tsu_id
         order by p_id
      SQL

      Participant.find_by_sql(sql)
    end

    ##
    # Fetch the netids associated with scheduled study segment identifiers
    #
    def fetch_netids_from_psc_report_rows
      if rpt = psc.scheduled_activities_report(options)
        if rows = rpt["rows"]
          net_ids = associate_scheduled_study_segment_ids_with_netids(rows)
        end
      end
      net_ids
    end

    def associate_scheduled_study_segment_ids_with_netids(rows)
      net_ids = {}
      rows.each do |row|
        if row["scheduled_study_segment"]
          net_ids[row["scheduled_study_segment"]["grid_id"]]  = row["responsible_user"]
        end
      end
      net_ids
    end


    ##
    # Delegate to Contact#last_contact and collect those into a Hash keyed by participant id
    # @param [Array<Integer>]
    # @return [Hash<Integer, Contact>]
    def last_contacts(participant_identifiers)
      result = Hash.new
      if lc = Contact.last_contact(participant_identifiers)
        lc.each do |c|
          result[c.participant_id.to_i] = c
        end
      end
      result
    end

    ##
    # Delegate to PpgStatusHistory#current_status and collect those into a Hash keyed by participant id
    # @param [Array<Integer>]
    # @return [Hash<Integer, PpgStatusHistory>]
    def ppg_statuses(participant_identifiers)
      result = Hash.new
      if ppgs = PpgStatusHistory.current_status(participant_identifiers)
        ppgs.each do |ppg|
          result[ppg.participant_id.to_i] = ppg
        end
      end
      result
    end

    ##
    # Generate a csv of the data collected
    # @return [FasterCSV]
    def generate_report
      statuses = case_statuses
      p_ids = statuses.collect { |c| c.q_id }

      net_ids = fetch_netids_from_psc_report_rows
      last_contacts = last_contacts(p_ids)
      current_ppg_statuses = ppg_statuses(p_ids)

      Rails.application.csv_impl.generate do |csv|
        csv << REPORT_HEADERS
        statuses.each do |c|
          last_contact = last_contacts[c.q_id.to_i]
          ppg_status = current_ppg_statuses[c.q_id.to_i]
          csv << [
            net_ids.has_key?(c.q_event_identifier) ? net_ids[c.q_event_identifier] : "n/a",
            c.p_id,
            c.q_first_name,
            c.q_last_name,
            c.q_event_date,
            c.q_event_time,
            c.q_event_name,
            last_contact.nil? ? "n/a" : last_contact.contact_date.to_s,
            last_contact.nil? ? "n/a" : last_contact.contact_start_time,
            last_contact.nil? ? "n/a" : last_contact.contact_end_time,
            last_contact.nil? ? "n/a" : last_contact.contact_comment,
            ppg_status.nil?   ? "n/a" : ppg_status.ppg_status_code,
            ppg_status.nil?   ? "n/a" : NcsCode.for_attribute_name_and_local_code(:ppg_status_code, ppg_status.ppg_status_code),
            last_contact.nil? ? "n/a" : last_contact.contact_language.to_s,
            last_contact.nil? ? "n/a" : last_contact.contact_disposition,
            last_contact.nil? ? "n/a" : NcsCode.for_attribute_name_and_local_code(:contact_type_code, last_contact.contact_type_code),
            c.q_phone,
            c.q_address_one,
            c.q_address_two,
            c.q_city,
            c.q_state,
            c.q_zip,
            c.q_tsu_id,
            c.q_ssu_id,
            c.q_high_intensity ? "HI" : "LO"
          ]
        end
      end

    end

  end
end

# select part.id as q_id, part.p_id, pers.first_name as q_first_name, pers.last_name as q_last_name,
#        max(e.event_start_date) as q_event_date, event_code.display_text as q_event_name,
#        t.phone_nbr as q_phone,
#        a.address_one as q_address_one, a.address_two as q_address_two, a.city as q_city,
#        state_code.display_text as q_state, a.zip as q_zip
# from participants part
#   left outer join participant_person_links ppl on ppl.participant_id = part.id
#   left outer join people pers on pers.id = ppl.person_id
#   left outer join events e on e.participant_id = part.id
#   left outer join telephones t on t.person_id = pers.id
#   left outer join addresses a on a.person_id = pers.id
#   left outer join ncs_codes state_code on state_code.local_code = a.state_code
#   left outer join ncs_codes event_code on event_code.local_code = e.event_type_code
# where ppl.relationship_code = 1
#   and scheduled_study_segment_identifier in ('b3e4b432-b4f6-4b27-ad6b-6a37e17da5ab', 'fdbf8c20-7805-4d7f-b82c-ee3624641509')
#   and state_code.list_name = 'STATE_CL1'
#   and event_code.list_name = 'EVENT_TYPE_CL1'
# group by part.id, part.p_id, pers.first_name, pers.last_name,
#          e.event_start_date, event_code.display_text, t.phone_nbr,
#          a.address_one, a.address_two, a.city, state_code.display_text, a.zip
# order by p_id
