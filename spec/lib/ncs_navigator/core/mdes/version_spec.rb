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
  end
end
