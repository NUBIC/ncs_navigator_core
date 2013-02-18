require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe PregnancyScreener do
    it_should_behave_like 'a survey title acceptor', '_PregScreen_' do
      let(:populator) { PregnancyScreener }
    end
  end
end
