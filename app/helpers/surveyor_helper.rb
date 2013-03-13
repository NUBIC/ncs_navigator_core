# -*- coding: utf-8 -*-


module SurveyorHelper
  include Surveyor::Helpers::SurveyorHelperMethods

  ##
  # Override to handle multi-part surveys
  def next_section
    # use copy in memory instead of making extra db calls
    if @sections.last == @section
      txt = t('surveyor.next_section').html_safe
      if @activity_plan.final_survey_part?(@response_set, @event)
        txt = t('surveyor.click_here_to_finish').html_safe
      end
      submit_tag(txt, :name => "finish")
    else
      submit_tag(t('surveyor.next_section').html_safe, :name => "section[#{@sections[@sections.index(@section)+1].id}]")
    end
  end

  # Questions
  def q_text(obj, context=nil)
    @n ||= 0
    return image_tag(obj.text) if obj.is_a?(Question) and obj.display_type == "image"
    return obj.render_question_text(context) if obj.is_a?(Question) and (obj.dependent? or obj.display_type == "label" or obj.part_of_group?)
    "#{obj.render_question_text(context)}"
  end



end