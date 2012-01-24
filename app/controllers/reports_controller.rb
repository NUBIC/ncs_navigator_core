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

    if request.post?
      @outfile = "case_status_report_" + Time.now.strftime("%m-%d-%Y") + ".csv"

      sql = <<-SQL
        select part.p_id, pers.first_name as q_first_name, pers.last_name as q_last_name,
         max(e.event_start_date) as q_event_date, event_code.display_text as q_event_name, c.contact_date as q_last_contact_date,
         ppg.ppg_status_code as q_ppg_status, language_code.display_text as q_language, c.contact_disposition as q_contact_disposition,
         t.phone_nbr as q_phone, a.address_one as q_address_one, a.city as q_city, state_code.display_text as q_state, a.zip as q_zip
         from participants part
         left outer join participant_person_links ppl on ppl.participant_id = part.id
         left outer join people pers on pers.id = ppl.person_id
         left outer join events e on e.participant_id = part.id
         left outer join contact_links cl on cl.event_id = e.id
         left outer join contacts c on cl.contact_id = c.id
         left outer join ppg_status_histories ppg on ppg.participant_id = part.id
         left outer join telephones t on t.person_id = pers.id
         left outer join addresses a on a.person_id = pers.id
         left outer join ncs_codes state_code on state_code.local_code = a.state_code
         left outer join ncs_codes language_code on language_code.local_code = c.contact_language_code
         left outer join ncs_codes event_code on event_code.local_code = e.event_type_code
         where ppl.relationship_code = 1
         and e.event_start_date between '#{@start_date}' and '#{@end_date}'
         and state_code.list_name = 'STATE_CL1'
         and language_code.list_name = 'LANGUAGE_CL2'
         and event_code.list_name = 'EVENT_TYPE_CL1'
         and c.contact_date = (select max(c1.contact_date) from contacts c1
        	left outer join contact_links cl1 on cl1.contact_id = c1.id
        	left outer join events e1 on e1.id = cl1.event_id
        	where e1.participant_id = part.id)
         group by p_id, pers.first_name, pers.last_name,
         e.event_start_date, event_code.display_text, c.contact_date,
         ppg.ppg_status_code, language_code.display_text, c.contact_disposition,
         t.phone_nbr, a.address_one, a.city, state_code.display_text, a.zip
         order by p_id
      SQL

      @case_statuses = Participant.find_by_sql(sql)

      headers = [
        "Participant ID",
        "First Name",
        "Last Name",
        "Next Event Date",
        "Event Name",
        "Last Contact Date",
        "PPG Status",
        "Language",
        "Last Contact Disposition",
        "Phone Number",
        "Address One",
        "City",
        "State",
        "Zip"
      ]

      csv_data = FasterCSV.generate do |csv|
        csv << headers
        @case_statuses.each do |c|
          csv << [
            c.p_id,
            c.q_first_name,
            c.q_last_name,
            c.q_event_date,
            c.q_event_name,
            c.q_last_contact_date,
            c.q_ppg_status,
            c.q_language,
            c.q_contact_disposition,
            c.q_phone,
            c.q_address_one,
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