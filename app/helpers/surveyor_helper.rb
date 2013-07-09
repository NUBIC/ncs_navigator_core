# -*- coding: utf-8 -*-


module SurveyorHelper
  include Surveyor::Helpers::SurveyorHelperMethods

  ##
  # Override to handle multi-part surveys
  def next_section
    # use copy in memory instead of making extra db calls
    if @sections.last == @section
      txt = t('surveyor.next_section').html_safe
      if !@response_set.participant || @activity_plan.final_survey_part?(@response_set, @event)
        txt = t('surveyor.click_here_to_finish').html_safe
      end
      submit_tag(txt, :name => "finish")
    else
      submit_tag(t('surveyor.next_section').html_safe, :name => "section[#{@sections[@sections.index(@section)+1].id}]")
    end
  end

  # Questions
  def q_text(q, context=nil, locale=nil)
    "#{q.text_for(nil, context, locale)}"
  end

  def no_event_section_menu_message(response_set)
    rs_type = "Survey"
    if response_set.try(:non_interview_report_associated?)
      rs_type = "Non Interview Report"
    elsif response_set.try(:participant_consent_associated?)
      rs_type = "Participant Consent"
    elsif response_set.try(:instrument_associated?)
      rs_type = "Instrument"
    end
    "No Event associated with this #{rs_type}."
  end

end
