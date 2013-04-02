require 'spec_helper'

module NcsNavigator::Core::Mdes
  describe Version do
    def set_db_version_number(value)
      ActiveRecord::Base.connection.tap do |conn|
        ct = conn.select_one('SELECT COUNT(*) FROM mdes_version')
        if ct['count'].to_i == 0
          conn.execute("INSERT INTO mdes_version (number) VALUES (%s)" % conn.quote(value))
        else
          conn.execute("UPDATE mdes_version SET number=%s" % conn.quote(value))
        end
      end
    end

    def remove_db_version_number
      ActiveRecord::Base.connection.tap do |conn|
        conn.execute("DELETE FROM mdes_version")
      end
    end

    describe '#number' do
      it 'reflects the number in the mdes_version table' do
        set_db_version_number '8.7'
        Version.new.number.should == '8.7'
      end

      it 'throws an exception if the number is not set' do
        remove_db_version_number
        expect { Version.new.number }.should raise_error(/No MDES version set for this deployment yet./)
      end
    end

    describe '#specification' do
      let(:actual) { Version.new.specification }
      let(:version_number) { '2.1' }

      before do
        set_db_version_number version_number
      end

      it 'is a specification instance' do
        actual.should be_a(NcsNavigator::Mdes::Specification)
      end

      it 'reflects the version number' do
        actual.version.should == version_number
      end
    end

    describe '.set!' do
      it 'fails if set to nil' do
        expect { Version.set!(nil) }.should raise_error(/MDES version cannot be blank./)
      end

      it 'sets the version if none is set' do
        remove_db_version_number

        Version.set!('3.0')
        Version.new.number.should == '3.0'
      end

      describe 'when a version is already set' do
        before do
          set_db_version_number '2.0'
        end

        it 'throws an exception if the new version is different' do
          expect { Version.set!('2.1') }.
            should raise_error(/This deployment already has an MDES version \(2\.0\)\. Use a migrator to change MDES versions\./)
        end

        it 'does nothing if the new version is the same' do
          expect { Version.set!('2.0') }.should_not raise_error
        end
      end
    end

    describe '.change!' do
      it 'fails if changed to nil' do
        expect { Version.change!(nil) }.should raise_error(/MDES version cannot be blank./)
      end

      it 'fails if no version is set' do
        remove_db_version_number

        expect { Version.change!('3.0') }.to raise_error('No MDES version set for this deployment yet.')
      end

      it 'when a version is already set it changes the version' do
        set_db_version_number '2.0'

        Version.change!('2.1')
        Version.new.number.should == '2.1'
      end
    end

    describe '#<=>' do
      let(:version) { Version.new('3.1') }

      shared_context 'Mdes::Version comparisons' do
        it 'is -1 when compared to a greater value' do
          (version <=> greater_value).should == -1
        end

        it 'is 0 when compared to an equivalent value' do
          (version <=> same_value).should == 0
        end

        it 'is +1 when compared to a lesser value' do
          (version <=> lesser_value).should == 1
        end
      end

      describe 'with another Mdes::Version' do
        let(:greater_value) { Version.new('3.5') }
        let(:same_value)    { Version.new('3.1') }
        let(:lesser_value)  { Version.new('2.2') }

        include_context 'Mdes::Version comparisons'
      end

      describe 'with a string' do
        let(:greater_value) { '4.8' }
        let(:same_value)    { '3.1' }
        let(:lesser_value)  { '1.1' }

        include_context 'Mdes::Version comparisons'
      end

      it 'is not comparable to a float' do
        (version <=> 3.1).should be_nil
      end

      it 'is not comparable to an integer' do
        (version <=> 3).should be_nil
      end

      it 'is not comparable to nil' do
        (version <=> nil).should be_nil
      end

      it 'reproduces the ordering for all known MDES versions' do
        scrambled_versions = SUPPORTED_VERSIONS.
          sort_by { rand }.collect { |n| Version.new(n) }

        scrambled_versions.sort.collect(&:number).should ==
          SUPPORTED_VERSIONS
      end
    end

    describe '#matches?' do
      def v(number)
        Version.new(number)
      end

      describe 'with a single version' do
        it 'matches the same version' do
          v('2.2').matches?('2.2').should be_true
        end

        it 'does not match a lesser version' do
          v('2.2').matches?('2.1').should be_false
        end

        it 'does not match a greater version' do
          v('2.2').matches?('3.1').should be_false
        end
      end

      describe 'with =' do
        it 'matches the same version' do
          v('2.2').matches?('= 2.2').should be_true
        end

        it 'does not match a lesser version' do
          v('2.2').matches?('= 2.1').should be_false
        end

        it 'does not match a greater version' do
          v('2.2').matches?('= 2.4').should be_false
        end
      end

      describe 'with <' do
        it 'does not match the same version' do
          v('2.2').matches?('< 2.2').should be_false
        end

        it 'does not match a lesser version' do
          v('2.2').matches?('< 2.0').should be_false
        end

        it 'matches a greater version' do
          v('2.2').matches?('< 2.4').should be_true
        end
      end

      describe 'with <=' do
        it 'matches the same version' do
          v('2.2').matches?('<= 2.2').should be_true
        end

        it 'does not match a lesser version' do
          v('2.2').matches?('<= 2.1').should be_false
        end

        it 'matches a greater version' do
          v('2.2').matches?('<= 3.0').should be_true
        end
      end

      describe 'with >' do
        it 'does not match the same version' do
          v('2.2').matches?('> 2.2').should be_false
        end

        it 'matches a lesser version' do
          v('2.2').matches?('> 2.0').should be_true
        end

        it 'does not match a greater version' do
          v('2.2').matches?('> 2.3').should be_false
        end
      end

      describe 'with >=' do
        it 'matches the same version' do
          v('2.2').matches?('>= 2.2').should be_true
        end

        it 'matches a lesser version' do
          v('2.2').matches?('>= 2.1').should be_true
        end

        it 'does not match a greater version' do
          v('2.2').matches?('>= 3.8').should be_false
        end
      end

      it 'throws an exception with some other comparator op' do
        expect { v('2.0').matches?('<< 3.4') }.
          to raise_error('Unsupported comparison operation or version name in "<< 3.4"')
      end

      it 'throws an exception without a version' do
        expect { v('2.0').matches?('<=') }.
          to raise_error('Unsupported comparison operation or version name in "<="')
      end
    end
  end
end
