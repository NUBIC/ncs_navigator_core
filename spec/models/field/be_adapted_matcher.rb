RSpec::Matchers.define :be_adapted do |model|
  match do |actual|
    actual.should respond_to(:target)

    actual.target.should == model
  end
end
