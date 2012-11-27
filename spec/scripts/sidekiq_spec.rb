require 'spec_helper'

describe 'script/sidekiq.sh' do
  let(:path) { Rails.root.join('script/sidekiq.sh') }

  it 'is executable' do
    File.stat(path).should be_executable
  end
end
