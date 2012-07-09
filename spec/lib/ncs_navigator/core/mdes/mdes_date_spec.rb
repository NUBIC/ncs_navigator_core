require 'spec_helper'

module NcsNavigator::Core::Mdes
  describe MdesDate do
    describe 'when created from a string' do
      describe 'the year' do
        it 'is converted to a code if it starts with 9' do
          MdesDate.new('9666-01-05').year.should == -6
        end

        it 'is treated as a year value otherwise' do
          MdesDate.new('2050-03-12').year.should == 2050
        end
      end

      describe 'the month' do
        it 'is converted to a code if it starts with 9' do
          MdesDate.new('2012-97-01').month.should == -7
        end

        it 'is kept as an integer otherwise' do
          MdesDate.new('2011-03-09').month.should == 3
        end
      end

      describe 'the day' do
        it 'is converted to a code if it starts with 9' do
          MdesDate.new('1979-03-92').day.should == -2
        end

        it 'is kept as an integer otherwise' do
          MdesDate.new('9666-95-04').day.should == 4
        end
      end
    end

    describe 'when created from a hash' do
      {
        :year => 2011,
        :month => 10,
        :day => 7
      }.each do |key, concrete_value|
        describe key.inspect do
          it 'is kept when a code' do
            MdesDate.new(key => -3).send(key).should == -3
          end

          it 'is kept when concrete' do
            MdesDate.new(key => concrete_value).send(key).should == concrete_value
          end

          it 'is unknown when omitted' do
            MdesDate.new({}).send(key).should == -6
          end
        end
      end
    end

    describe '#coded?' do
      it 'is true if the year is coded' do
        MdesDate.new('9555-03-07').should be_coded
      end

      it 'is true if the month is coded' do
        MdesDate.new('2014-93-02').should be_coded
      end

      it 'is true if the day is coded' do
        MdesDate.new('2011-01-97').should be_coded
      end
    end

    describe '#to_date' do
      it 'is the exact date when fully concrete' do
        MdesDate.new('2003-04-05').to_date.should == Date.new(2003, 4, 5)
      end

      %w(9666-93-91 2010-91-92 2000-03-94).each do |coded_value|
        it 'is nil when coded' do
          MdesDate.new(coded_value).to_date.should be_nil
        end
      end
    end

    describe '#to_approximate_date' do
      it 'is the exact date when fully concrete' do
        MdesDate.new('1980-08-08').to_approximate_date.should == Date.new(1980, 8, 8)
      end

      it 'is nil when the year is coded' do
        MdesDate.new('9333-01-01').to_approximate_date.should be_nil
      end

      it 'approximates the day to 1' do
        MdesDate.new('1990-03-94').to_approximate_date.should == Date.new(1990, 3, 1)
      end

      it 'approximates the month to 1' do
        MdesDate.new('2000-95-18').to_approximate_date.should == Date.new(2000, 1, 18)
      end
    end

    describe '#to_s' do
      it 'works when concrete' do
        MdesDate.new(:year => 1997, :month => 6, :day => 1).to_s.should == '1997-06-01'
      end

     it 'works when the year is coded' do
        MdesDate.new(:year => -4, :month => 3, :day => 9).to_s.should == '9444-03-09'
      end

      it 'works when the month is coded' do
        MdesDate.new(:year => 2016, :month => -2, :day => 3).to_s.should == '2016-92-03'
      end

      it 'works when the day is coded' do
        MdesDate.new(:year => 2015, :month => 2, :day => -3).to_s.should == '2015-02-93'
      end
    end

    describe '#to_approximate_s' do
      it 'works when concrete' do
        MdesDate.new(:year => 1997, :month => 6, :day => 1).to_approximate_s.should == '1997-06-01'
      end

      it 'is nil when the year is coded' do
        MdesDate.new('9333-01-01').to_approximate_s.should be_nil
      end

      it 'approximates the day to 1' do
        MdesDate.new('1990-03-94').to_approximate_s.should == '1990-03-01'
      end

      it 'approximates the month to 1' do
        MdesDate.new('2000-95-18').to_approximate_s.should == '2000-01-18'
      end
    end
  end
end
