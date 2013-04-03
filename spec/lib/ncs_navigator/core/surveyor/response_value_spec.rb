require 'spec_helper'

module NcsNavigator::Core::Surveyor
  describe ResponseValue do
    describe '.value_fields' do
      %w(
        datetime_value
        float_value
        integer_value
        string_value
        text_value
      ).each do |f|
        it "includes #{f}" do
          ResponseValue.value_fields.should include(f)
        end
      end
    end
  end

  describe 'Response value accessor' do
    let(:r) { Factory(:response, :answer => a, :question => q) }
    let(:a) { Factory(:answer) }
    let(:q) { Factory(:question) }

    t_zulu = '2000-01-01T00:00:00Z'
    t_utc_m6 = '2000-01-01T00:00:00-0600'
    t_utc_p1 = '2000-01-01T00:00:00+0100'
    dt_zulu = Time.parse(t_zulu)
    dt_utc_m6 = Time.parse(t_utc_m6)
    dt_utc_p1 = Time.parse(t_utc_p1)
    d = Date.new(2000, 01, 01)
    d_world = '2000-01-01'
    d_us = '01/01/2000'
    t_noon_str = '12:00'
    t_noon = Time.parse(t_noon_str)

    # rclass      column name         input           persisted   output
    [
     # String echo.
     'string',    'string_value',     'foo',          'foo',      'foo',

     # Integer -> string coercion.
     'string',    'string_value',     42,             '42',       '42',

     # Integer echo.
     'integer',   'integer_value',    42,             42,         42,

     # Float echo.
     'float',     'float_value',      10.1,           10.1,       10.1,

     # Text isn't the same as string.
     'text',      'text_value',       'foo',          'foo',      'foo',

     # Datetime echo.
     'datetime',  'datetime_value',   dt_zulu,        dt_zulu,    dt_zulu,

     # Date echo.
     'date',      'datetime_value',   d,              d.to_time,  d,

     # YYYY-MM-DD strings as dates.
     # Surveyor uses a datetime field to store datetimes, dates, and times.
     # This is why you see the #to_time conversions.  They're kind of gross,
     # but we have to live with it.
     'date',      'datetime_value',   d_world,        d.to_time,  d,

     # MM/DD/YYYY strings as dates.
     'date',      'datetime_value',   d_us,           d.to_time,  d,

     # HH:MM times.
     'time',      'datetime_value',   t_noon_str,     t_noon,     t_noon,

     # ISO8601 times as strings.
     'datetime',  'datetime_value',   t_zulu,         dt_zulu,    dt_zulu,
     'datetime',  'datetime_value',   t_utc_m6,       dt_utc_m6,  dt_utc_m6,
     'datetime',  'datetime_value',   t_utc_p1,       dt_utc_p1,  dt_utc_p1

    ].each_slice(5) do |response_class, mapped_field, input, persisted, output|
      describe "with response class #{response_class}" do
        before do
          a.update_attribute(:response_class, response_class)
        end

        it "returns #{input.inspect} when given #{input.inspect}" do
          r.value = input

          r.value.should == input
        end

        describe "after setting #{input.inspect} and saving" do
          let(:sr) { Response.find(r.id) }

          before do
          end

          it "sets #{mapped_field} to #{persisted.inspect}" do
            r.value = input
            r.save!

            sr.send(mapped_field).should == persisted
          end

          it 'resets all other value fields' do
            ResponseValue.value_fields.each do |f|
              r.send("#{f}=", "100")
            end

            r.value = input
            r.save!

            vs = (ResponseValue.value_fields - [mapped_field]).map { |f| sr.send(f) }

            vs.all?(&:nil?).should be_true
          end

          it "returns #{output.inspect}" do
            r.value = input
            r.save!

            sr.value.should == output
          end
        end
      end
    end

    describe '#value' do
      it 'is read back from the database on reload' do
        a.update_attribute(:response_class, 'integer')
        r.value = 42
        r.save!
        r.value = '42'
        r.reload

        r.value.should == 42
      end
    end

    describe 'with response class answer' do
      before do
        a.update_attribute(:response_class, 'answer')
      end

      describe '#value=' do
        describe 'in production' do
          before do
            Rails.env.stub!(:production? => true)
          end

          it 'does not set anything when persisting' do
            r.value = 'foo'
            r.save!

            r.reload.value.should be_nil
          end
        end

        describe 'not in production' do
          before do
            Rails.env.stub!(:production? => false)
          end

          it 'raises CannotSetValue when persisting' do
            r.value = 'foo'

            expect { r.save }.to raise_error(ResponseValue::CannotSetValue)
          end
        end
      end
    end
  end
end
