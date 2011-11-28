require 'spec_helper'

module NcsNavigator::Core
  describe MdesInstrumentSurvey do
    let(:instrument_text) {
      <<-INSTR
survey "INS_QUE_etc_v1.1" do
  section "Intro" do
    q_r_fname "First name",
      :pick=>:one,
      :data_export_identifier=>"PRE_PREG.R_FNAME"
      a :string
      a_neg_1 "Refused"
      a_neg_2 "Don't know"

    q_TUBE_STATUS_TUBE_TYPE_1_VISIT_1 "Blood tube collection status",
      :pick => :one,
      :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_STATUS"
      a_1 "Full draw"
      a_2 "Short draw"
      a_3 "No draw"
  end
end
INSTR
    }
    subject { ::Surveyor::Parser.new.parse(instrument_text) }

    it 'is mixed into Survey' do
      ::Survey.ancestors.should include(MdesInstrumentSurvey)
    end

    describe '#mdes_table_map' do
      let(:map) { subject.mdes_table_map }

      it 'maps from associated table ident to variable name to question' do
        map['pre_preg'][:variables]['r_fname'][:questions].should ==
          [::Question.find_by_reference_identifier('r_fname')]
      end

      describe 'with fixed values' do
        it 'has the right the table name' do
          map['spec_blood_tube[tube_type=1]'][:table].should == 'spec_blood_tube'
        end

        it 'has the fixed value' do
          map['spec_blood_tube[tube_type=1]'][:variables]['tube_type'][:fixed_value].should == '1'
        end
      end
    end
  end
end
