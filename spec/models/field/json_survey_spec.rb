require 'spec_helper'

module Field
  describe JsonSurvey do
    describe '#to_json' do
      it 'returns what it wraps' do
        js = JsonSurvey.new('{"b":"c"}')

        { 'a' => js }.to_json.should == %q{{"a":{"b":"c"}}}
      end
    end
  end
end
