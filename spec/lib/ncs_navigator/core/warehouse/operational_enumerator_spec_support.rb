# For no reason I can tell, shared example groups in RSpec are global names. In
# order to be used in each operational enumerator spec, these tiny shared groups
# have to be defined out here instead of close to the tests where they'd make
# sense.

shared_examples 'one to one' do
  it 'creates one record per source entry' do
    results.collect(&:class).should == [warehouse_model]
  end
end

shared_context 'mapping test' do
  before do
    # ignore unused so we can see the mapping failures
    OperationalEnumerator.on_unused_columns :ignore
  end

  after do
    OperationalEnumerator.on_unused_columns :fail
  end

  def verify_mapping(core_field, core_value, wh_field, wh_value=nil)
    wh_value ||= core_value
    core_model.last.tap { |p| p.send("#{core_field}=", core_value) }.save!
    results.last.send(wh_field).should == wh_value
  end

  def self.verify_mapping(core_field, core_value, wh_field, wh_value=nil, addtl_msg=nil)
    it "maps #{core_field} to #{wh_field} #{addtl_msg}" do
      verify_mapping(core_field, core_value, wh_field, wh_value)
    end
  end
end

