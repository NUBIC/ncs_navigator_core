# -*- coding: utf-8 -*-

module SurveyorHelper
  include Surveyor::Helpers::SurveyorHelperMethods

  def rc_to_as(type_sym)
    case type_sym.to_s
    when /(integer|float)/ then :string
    when /(datetime)/ then :string
    else type_sym
    end
  end

end