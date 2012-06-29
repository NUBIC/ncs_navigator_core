shared_examples 'an MDES time' do
  let(:time_setter) { "#{time_attribute}=" }

  def it_should_be_invalid
    record.should be_invalid
    record.errors.to_a.should == ["#{time_name} is invalid"]
  end

  it 'is invalid with an arbitrary string' do
    record.send(time_setter, 'foo')
    it_should_be_invalid
  end

  it "is invalid with a completely bad time" do
    record.send(time_setter, "66:66")
    it_should_be_invalid
  end

  it "is invalid with a nonsensical number of minutes" do
    record.send(time_setter, "23:77")
    it_should_be_invalid
  end

  it "is invalid with a nonsensical number of hours" do
    record.send(time_setter, "27:17")
    it_should_be_invalid
  end

  it 'is valid with an MDES coded time' do
    record.send(time_setter, '96:92')
    record.should_not be_invalid
  end

  it "is valid if given a valid 24hr time" do
    record.send(time_setter, "23:56")
    record.should_not be_invalid
  end

  it "is valid if given a valid 24hr time with trailing whitespace" do
    record.send(time_setter, "23:56   ")
    record.should_not be_invalid
  end

  it "is valid if blank" do
    record.send(time_setter, nil)
    record.should_not be_invalid
  end
end
