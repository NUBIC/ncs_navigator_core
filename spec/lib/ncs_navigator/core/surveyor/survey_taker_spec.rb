require 'spec_helper'

module NcsNavigator::Core::Surveyor
  describe SurveyTaker do
    let(:taker) { Object.new.extend(SurveyTaker) }
    let(:s) { @survey }
    let(:rs) { ResponseSet.new(:survey => s) }

    before(:all) do
      # Reduce log spam for easier profiling.
      ActiveRecord::Base.silence do
        @survey = Surveyor::Parser.new.parse(File.read(File.expand_path('../kitchen_sink_survey.rb', __FILE__)))
      end
    end

    it 'fills in a single choice' do
      taker.respond(rs) do |r|
        r.answer '2', '1'
      end

      rs.should have_response('2', '1')
    end

    it 'fills in multiple choices' do
      taker.respond(rs) do |r|
        r.answer '2', '1'
        r.answer '2', '3'
      end

      rs.should have_response('2', '1')
      rs.should have_response('2', '3')
    end

    describe 'using data export identifiers' do
      it 'fills in single choices' do
        taker.respond(rs) do |r|
          r.using_data_export_identifiers do |r|
            r.answer 'COOLING', '2'
          end
        end

        rs.should have_response('cooling_1', '2')
      end

      it 'fills in string fields' do
        taker.respond(rs) do |r|
          r.using_data_export_identifiers do |r|
            r.answer 'COOLING', 'other', :value => 'Aliens'
          end
        end

        rs.should have_response('cooling_1', 'other', 'Aliens')
      end
    end

    it 'fills in integer fields' do
      taker.respond(rs) do |r|
        r.answer 'pet', 'pet', :value => 3
      end

      rs.should have_response('pet', 'pet', 3)
    end

    it 'fills in string fields' do
      taker.respond(rs) do |r|
        r.answer 'montypython3', '1', :value => 'Brave Sir Robin'
      end

      rs.should have_response('montypython3', '1', 'Brave Sir Robin')
    end

    describe 'for questions with a single answer' do
      it 'fills in string fields' do
        taker.respond(rs) do |r|
          r.answer '2b', :value => 'What colors?'
        end

        rs.should have_response('2b', nil, 'What colors?')
      end

      it 'fills in string fields when no answer reference identifier is specified' do
        taker.respond(rs) do |r|
          r.answer 'montypython3', :value => 'Brave Sir Robin'
        end

        rs.should have_response('montypython3', '1', 'Brave Sir Robin')
      end

    end

    describe 'UnresolvableQuestion' do
      it 'is raised when reference identifiers cannot be resolved' do
        code = lambda do
          taker.respond(rs) do |r|
            r.answer 'wrong', :value => 'what'
          end
        end

        code.should raise_error(SurveyTaker::UnresolvableQuestion)
      end

      it 'is raised when data export identifiers cannot be resolved' do
        code = lambda do
          taker.respond(rs) do |r|
            r.using_data_export_identifiers do
              r.answer 'cooling_1', :value => 'what'
            end
          end
        end

        code.should raise_error(SurveyTaker::UnresolvableQuestion)
      end

      it 'does not shadow data export identifiers with reference identifiers' do
        # cooling_1 is a valid reference identifier, but it isn't a valid data
        # export identifier.
        code = lambda do
          taker.respond(rs) do |r|
            r.using_data_export_identifiers do
              r.answer 'cooling_1', :value => 'what'
            end

            r.answer 'cooling_1', '1'
          end
        end

        code.should raise_error(SurveyTaker::UnresolvableQuestion)
      end
    end

    describe 'UnresolvableAnswer' do
      it 'is raised when answer reference identifiers cannot be resolved' do
        code = lambda do
          taker.respond(rs) do |r|
            r.answer 'cooling_1', 'wrong'
          end
        end

        code.should raise_error(SurveyTaker::UnresolvableAnswer)
      end
    end

    describe 'AmbiguousAnswer' do
      it 'is raised when an implicit target is given for a question with multiple answers' do
        code = lambda do
          taker.respond(rs) do |r|
            r.answer 'improv_start', :value => 'All'
          end
        end

        code.should raise_error(SurveyTaker::AmbiguousAnswer)
      end
    end
  end
end
