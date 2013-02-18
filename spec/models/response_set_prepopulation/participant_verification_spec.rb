require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe ParticipantVerification do
    it_should_behave_like 'a survey title acceptor', '_ParticipantVerif_' do
      let(:populator) { ParticipantVerification }
    end
  end
end
