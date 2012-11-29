require 'spec_helper'

module NcsNavigator::Core::Field
  describe LogFormatter do
    let(:model) { Merge.new }
    let(:formatter) { LogFormatter.new(model) }

    describe '#call' do
      let(:time) { Time.parse('1999-12-31T18:00:00-0600') }
      let(:message) { msg = formatter.call('INFO', time, 'foo', 'bar') }
      let(:components) { message.split(/\s+/) }

      it 'inserts the current UTC time' do
        components[0].should == '2000-01-01T00:00:00Z'
      end

      it 'inserts the process ID' do
        components[1].should == $$.to_s
      end

      it 'inserts the model class name' do
        components[2].should == 'Merge'
      end

      it 'inserts the model ID' do
        model.stub!(:id => 1)

        components[3].should == '1'
      end

      it 'inserts the model object ID' do
        components[4].should == "(0x" + "%0#{LogFormatter::MAXLEN}x" % model.object_id + ")"
      end

      it 'inserts the severity' do
        components[5].should == 'INFO'
      end

      it 'inserts the message' do
        components.last.should == 'bar'
      end

      it 'ends with a newline' do
        message.last.should == "\n"
      end
    end
  end
end
