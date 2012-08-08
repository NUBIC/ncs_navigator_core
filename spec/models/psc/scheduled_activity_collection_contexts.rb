require 'spec_helper'

shared_context 'collection from report' do
  let(:source) do
    f = File.read(File.expand_path('../ex1.json', __FILE__))

    JSON.parse(f)
  end
end

shared_context 'collection from schedule' do
  let(:source) do
    f = File.read(File.expand_path('../participant_schedule.json', __FILE__))

    JSON.parse(f)
  end
end
