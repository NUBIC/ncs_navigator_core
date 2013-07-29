module InstrumentsHelper
  def determine_links_for_editing(instrument, rs)
    if instrument.person.try(:participant)
      edit_instrument_responses_link(rs)
    else
      restart_link(rs) + edit_instrument_responses_link(rs)
    end
  end

  def restart_link(rs)
    link_to "Recreate Participant and Restart Screener",
      restart_screener_for_ineligible_path(response_set_code: rs.access_code),
      class: "edit_link icon_link",
      confirm: 'Are you sure you would like to restart?',
      title: rs.survey.title
  end

  def edit_instrument_responses_link(rs)
    link_to "Edit Instrument Responses",
      surveyor.edit_my_survey_path(survey_code: rs.survey.access_code, response_set_code: rs.access_code),
      class: "edit_link icon_link",
      title: rs.survey.title
  end
end