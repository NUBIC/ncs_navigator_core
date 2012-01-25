require 'fastercsv'
class ReportsController < ApplicationController

  def index
  end

  ##
  # Case Status Report
  # ------------------
  # Frequency  -
  #   Once a week Monday
  # Contents -
  #   SUID/participant ID
  #   Address (broken out into separate fields for Address 1, Address 2, City, State and zip)
  #   Phone Number
  #   Person Name (broken out into separate fields for First and Last)
  #   Date and Time of the next scheduled call attempt
  #   Date and Time of last call attempt
  #   Last Call Outcome
  #   PPG Status
  #   Instrument that is to be completed next
  #   Language we need to call in if other than English
  #   Use -
  #     Used to monitor weekly flow of cases.
  def case_status
    default_start_date = Date.today.to_s(:db)
    default_end_date   = 1.week.from_now.to_date.to_s(:db)

    @start_date = params[:start_date] || default_start_date
    @end_date   = params[:end_date] || default_end_date

    event_start_end_date_condition = "and e.event_start_date between '#{@start_date}' and '#{@end_date}'"
    if params[:pending_events].to_i == 1
      event_start_end_date_condition = "and e.event_end_date IS NULL"
    end

    if request.post?
      @outfile = "case_status_report_" + Time.now.strftime("%m-%d-%Y") + ".csv"

      sql = <<-SQL
        select part.id as q_id, part.p_id, pers.first_name as q_first_name, pers.last_name as q_last_name,
         max(e.event_start_date) as q_event_date, event_code.display_text as q_event_name,
         t.phone_nbr as q_phone,
         a.address_one as q_address_one, a.address_two as q_address_two, a.city as q_city,
         state_code.display_text as q_state, a.zip as q_zip
         from participants part
         left outer join participant_person_links ppl on ppl.participant_id = part.id
         left outer join people pers on pers.id = ppl.person_id
         left outer join events e on e.participant_id = part.id
         left outer join telephones t on t.person_id = pers.id
         left outer join addresses a on a.person_id = pers.id
         left outer join ncs_codes state_code on state_code.local_code = a.state_code
         left outer join ncs_codes event_code on event_code.local_code = e.event_type_code
         where ppl.relationship_code = 1
         #{event_start_end_date_condition}
         and state_code.list_name = 'STATE_CL1'
         and event_code.list_name = 'EVENT_TYPE_CL1'
         group by part.id, part.p_id, pers.first_name, pers.last_name,
         e.event_start_date, event_code.display_text, t.phone_nbr,
         a.address_one, a.address_two, a.city, state_code.display_text, a.zip
         order by p_id
      SQL

      case_statuses = Participant.find_by_sql(sql)
      p_ids = case_statuses.collect { |c| c.q_id }

      last_contacts = Contact.last_contact(p_ids).inject({}) do |hsh, c|
        hsh[c.participant_id.to_i] = c
      end

      current_ppg_statuses = PpgStatusHistory.current_status(p_ids).inject({}) do |hsh, s|
        hsh[s.participant_id.to_i] = s
      end

      headers = [
        "Participant ID",
        "First Name",
        "Last Name",
        "Next Event Date",
        "Event Name",
        "Last Contact Date",
        "Last Contact Start Time",
        "Last Contact End Time",
        "PPG Status",
        "Language",
        "Last Contact Disposition",
        "Phone Number",
        "Address One",
        "Address Two",
        "City",
        "State",
        "Zip"
      ]

      csv_data = FasterCSV.generate do |csv|
        csv << headers
        case_statuses.each do |c|
          # last_contact = c.last_contact
          last_contact = last_contacts[c.q_id]
          ppg_status = current_ppg_statuses[c.q_id]
          csv << [
            c.p_id,
            c.q_first_name,
            c.q_last_name,
            c.q_event_date,
            c.q_event_name,
            last_contact.nil? ? "n/a" : last_contact.contact_date.to_s,
            last_contact.nil? ? "n/a" : last_contact.contact_start_time,
            last_contact.nil? ? "n/a" : last_contact.contact_end_time,
            ppg_status.to_s,
            last_contact.nil? ? "n/a" : last_contact.contact_language.to_s,
            last_contact.nil? ? "n/a" : last_contact.contact_disposition,
            c.q_phone,
            c.q_address_one,
            c.q_address_two,
            c.q_city,
            c.q_state,
            c.q_zip
          ]
        end
      end
      send_data csv_data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}"
    end


  end

end