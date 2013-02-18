require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe PregnancyVisit do
    context 'class' do
      let(:populator) { PregnancyVisit }

      it_should_behave_like 'a survey title acceptor', '_PregVisit1_', '_PregVisit2_'
    end
  end
end
