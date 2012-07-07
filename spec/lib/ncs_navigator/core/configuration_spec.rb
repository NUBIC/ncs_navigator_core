require 'spec_helper'

module NcsNavigator::Core
  describe Configuration do
    let(:config)        { Configuration.new(suite_config) }
    let(:global_config) { Configuration.new }

    # This will need to be kept minimally valid
    let(:suite_config_hash) {
      {
        'Study Center' => {
          'sc_id' => '23000000',
          'recruitment_type_id' => '3',
          'sampling_units_file' => 'foo.csv'
        },
        'Staff Portal' => {
          'uri' => 'https://sp.example.edu/'
        },
        'Core' => {
          'uri' => 'https://ncsn.example.edu/',
        },
        'PSC' => {
          'uri' => 'https://psc.example.edu/'
        }
      }
    }

    let(:suite_config) { NcsNavigator::Configuration.new(suite_config_hash) }

    describe '#suite_configuration' do
      before do
        suite_config_hash['Core']['study_center_name'] = 'Local'
      end

      it 'is the provided instance if one is provided' do
        Configuration.new(suite_config).study_center_name.should == 'Local'
      end

      it 'is the global instance by default' do
        # value in spec/navigator.ini
        Configuration.new.study_center_name.should == 'Greater Chicago Study Center'
      end

      it 'reflects changes to the global instance' do
        c = Configuration.new
        c.study_center_name.should == 'Greater Chicago Study Center'
        begin
          NcsNavigator.configuration = suite_config
          c.study_center_name.should == 'Local'
        ensure
          Spec.reset_navigator_ini
        end
        c.study_center_name.should == 'Greater Chicago Study Center'
      end
    end

    describe '#study_center_short_name' do
      it 'comes from the suite configuration' do
        suite_config_hash['Study Center']['short_name'] = 'Bar'
        config.study_center_short_name.should == 'Bar'
      end
    end

    describe '#email_prefix' do
      it 'uniquely identifies the deployment' do
        env_name = ENV['CI_RUBY'] ? 'Ci' : 'Test'
        config.email_prefix.should == "[NCS Navigator Cases SC #{env_name}] "
      end
    end

    %w(right left).each do |side|
      describe "#footer_#{side}_logo_path" do
        let(:subject) { config.send("footer_#{side}_logo_path") }

        it 'is nil when not set in suite config' do
          subject.should be_nil
        end

        it 'is the basename only when set in suite config' do
          suite_config_hash['Study Center']["footer_logo_#{side}"] = '/a/b/f/quux.png'
          subject.should == 'quux.png'
        end
      end
    end

    describe '#psu' do
      it 'is the first PSU in the suite configuration' do
        global_config.psu.should == '20000030'
      end
    end

    describe '#psu_code' do
      it 'is the first PSU in the suite configuration' do
        global_config.psu_code.should == '20000030'
      end
    end

    %w(study_center_name study_center_phone_number with_specimens sync_log_level).each do |attr|
      describe "##{attr}" do
        it "is the corresponding value from the Core section" do
          suite_config_hash['Core'][attr] = 'foob'
          config.send(attr).should == 'foob'
        end

        it 'is nil if not set' do
          config.send(attr).should be_nil
        end
      end
    end

    %w(with_specimens? expanded_phase_two?).each do |meth|
      describe "##{meth}" do
        let(:subject) { config.send(meth) }

        it 'is false if the suite config value is not set' do
          subject.should be_false
        end

        it 'is true if the suite config value is true' do
          suite_config_hash['Core']['with_specimens'] = 'true'
          subject.should be_true
        end

        it 'is false if the suite config value is set to other than true' do
          suite_config_hash['Core']['with_specimens'] = 'T'
          subject.should be_false
        end
      end
    end

    describe '#recruitment_type_id' do
      it 'is the integer version of the suite config ID' do
        config.recruitment_type_id.should == 3
      end
    end

    describe '#mdes' do
      it 'is a Specification' do
        config.mdes.should be_a NcsNavigator::Mdes::Specification
      end
    end
  end
end
