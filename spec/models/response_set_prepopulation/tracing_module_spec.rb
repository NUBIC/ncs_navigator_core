require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe TracingModule do
    context 'class' do
      let(:populator) { TracingModule }

      it_should_behave_like 'a survey title acceptor', '_Tracing_'
    end
  end
end
