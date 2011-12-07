require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe UnusedInstrumentPassthrough do
    before do
      load_survey_string(<<-S1)
survey "INS_BIO_AdultBlood_DCI_EHPBHI_P2_V1.0" do
  section "A" do
    q_BLOOD_INTRO "I will now collect a blood sample. I will need to ask you some questions before I collect your blood sample.",
    :pick => :one,
    :data_export_identifier=>"SPEC_BLOOD.BLOOD_INTRO"
    a_1 "Continue"
    a_neg_1 "Refused"
  end
end
      S1

      load_survey_string(<<-S2)
survey "INS_QUE_PPGFollUp_INT_EHPBHILI_P2_V1.2" do
  section "CATI" do
    q_TIME_STAMP_1 "Insert date/time stamp",
    :data_export_identifier=>"PPG_CATI.TIME_STAMP_1"
    a :datetime, :custom_class => "datetime"
  end
end
      S2
    end

    let(:wh_config)   { NcsNavigator::Warehouse::Configuration.new }
    let(:passthrough) { UnusedInstrumentPassthrough.new(wh_config) }

    before do
      Survey.mdes_reset!
    end

    describe '#create_emitter', :slow do
      subject { passthrough.create_emitter }

      let(:model_tables) { subject.models.collect(&:mdes_table_name) }

      it 'includes PII' do
        subject.include_pii?.should be_true
      end

      it 'skips the ZIP' do
        subject.zip?.should be_false
      end

      it 'writes to a file in the tmp directory' do
        subject.filename.to_s.should == "#{Rails.root}/tmp/unused_imported_instrument_tables.xml"
      end

      it 'does not include models which are represented in the available surveys' do
        model_tables.should_not include('ppg_cati')
      end

      it 'does include instrument models which are not represented in the surveys' do
        model_tables.should include('pre_preg')
      end

      it 'does not include operational models' do
        model_tables.should_not include('person')
      end
    end

    describe '#import' do
      let(:mock_emitter) { mock(NcsNavigator::Warehouse::XmlEmitter) }

      it 'emits the XML' do
        passthrough.should_receive(:create_emitter).and_return(mock_emitter)
        mock_emitter.should_receive(:emit_xml)

        passthrough.import
      end
    end
  end
end
