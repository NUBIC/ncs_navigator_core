require 'spec_helper'

describe SubjectTagger do
  let(:message) { Mail::Message.new }
  let(:prefix) { NcsNavigatorCore.configuration.email_prefix }
  let(:tagger) { SubjectTagger }

  it 'prepends an origin tag' do
    tagger.delivering_email(message)

    message.subject.should =~ /^#{Regexp.escape(prefix)}/
  end

  it 'prepends an origin tag only once' do
    message.subject = prefix

    tagger.delivering_email(message)

    message.subject.should == prefix
  end
end
