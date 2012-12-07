require 'spec_helper'

describe InstrumentLabel do
  def il(text)
    InstrumentLabel.new(text)
  end

  describe '#version' do
    it 'returns the version component' do
      il('2.0:ins_que_lipregnotpreg_int_li_p2_v2.0').version.should == '2.0'
    end

    it 'returns nil if no version is specified' do
      il('ins_que_lipregnotpreg_int_li_p2_v2.0').version.should be_nil
    end
  end

  describe '#access_code' do
    it 'returns the access code' do
      il('2.0:ins_que_lipregnotpreg_int_li_p2_v2.0').access_code.should ==
        'ins_que_lipregnotpreg_int_li_p2_v2.0'
    end

    describe 'without a version' do
      it 'returns the entire label' do
        il('ins_que_lipregnotpreg_int_li_p2_v2.0').access_code.should ==
          'ins_que_lipregnotpreg_int_li_p2_v2.0'
      end
    end
  end

  describe '#ncs_code' do
    let!(:code) do
      NcsCode.create!(:display_text => 'FOO_BAR', :list_name => 'INSTRUMENT_TYPE_CL1', :local_code => -42)
    end

    before do
      Factory(:survey, :access_code => 'foo-bar', :title => 'Foo Bar', :instrument_type => -42)
    end

    it 'returns the NCS code for the instrument' do
      il('foo-bar').ncs_code.should == code
    end

    it 'returns nil if no code can be found' do
      il('wrong').ncs_code.should be_nil
    end
  end
end
