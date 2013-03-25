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

  it "writes address.address_one to address_one" do
    provider.build_address(:address_one => '31 Foo St')
    json['provider']['address_one'].should == '31 Foo St'
  end

  it "writes address.unit to unit" do
    provider.build_address(:unit => '9')
    json['provider']['unit'].should == '9'
  end
end
