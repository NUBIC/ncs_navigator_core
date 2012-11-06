require 'json'
require 'spec_helper'

describe ProviderSerializer do
  let(:provider) { Provider.new }
  let(:pbs_list) { PbsList.new }
  let(:serializer) { ProviderSerializer.new(provider) }

  def json
    JSON.parse(serializer.to_json({}))
  end

  it 'writes name_practice to name' do
    provider.name_practice = 'Foobar'

    json['provider']['name'].should == 'Foobar'
  end

  it 'writes provider_id -> location' do
    provider.provider_id = 'foo'

    json['provider']['location'].should == 'foo'
  end

  it 'writes pbs_list.practice_num to practice_num' do
    provider.pbs_list = pbs_list
    pbs_list.practice_num = 2

    json['provider']['practice_num'].should == 2
  end

  describe 'if the provider does not have a PbsList' do
    it 'writes null to practice_num' do
      json['provider']['practice_num'].should be_nil
    end
  end

  it 'writes recruited? to recruited' do
    provider.stub!(:recruited? => true)
    json['provider']['recruited'].should be_true

    provider.stub!(:recruited? => false)
    json['provider']['recruited'].should be_false
  end
end
