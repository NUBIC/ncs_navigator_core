# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module SurveyCompletion
  include NcsNavigator::Core::Surveyor::SurveyTaker

  class Responder
    def initialize(r)
      @respondent = r
    end

    def a(ref, val, opts = nil)
      if opts
        @respondent.answer(ref, val, opts)
      else
        if val.respond_to?(:local_code)
          @respondent.answer(ref, val.local_code.to_s.sub('-', 'neg_'))
        elsif val.is_a?(Hash)
          @respondent.answer(ref, val[:reference_identifier])
        else
          @respondent.answer(ref, :value => val)
        end
      end
    end

    def yes(ref)
      @respondent.answer(ref, NcsCode::YES.to_s)
    end

    def no(ref)
      @respondent.answer(ref, NcsCode::NO.to_s)
    end

    def refused(ref)
      @respondent.answer(ref, 'neg_1')
    end

    def dont_know(ref)
      @respondent.answer(ref, 'neg_2')
    end
  end

  def take_survey(survey, response_set)
    respond(response_set, survey) do |r|
      r.using_data_export_identifiers do |r|
        yield Responder.new(r)
      end
    end

    response_set.save!
  end
end
