require 'spec_helper'

shared_examples_for 'a time-bounded task' do |end_field, end_value|
  let(:model) { subject }

  class_eval <<-END
    def set_end_field(value)
      model.send("#{end_field}=", value)
    end
  END

  describe '#closed?' do
    it "returns false if #{end_field} is not set" do
      set_end_field(nil)

      model.should_not be_closed
    end

    it "returns true if #{end_field} is set to #{end_value}" do
      set_end_field(end_value)

      model.should be_closed
    end
  end

  describe '#open?' do
    it "returns true if #{end_field} is not set" do
      set_end_field(nil)

      model.should be_open
    end

    it "returns false if #{end_field} is set to #{end_value}" do
      set_end_field(end_value)

      model.should_not be_open
    end
  end
end
