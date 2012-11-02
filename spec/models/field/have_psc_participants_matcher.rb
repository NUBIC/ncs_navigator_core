RSpec::Matchers.define :have_psc_participants do |*expected|
  match do |collection|
    @not_found = []

    expected.each do |participant|
      ok = collection.detect { |_, pscp| pscp.participant == participant }

      if !ok
        @not_found << participant
      end
    end

    @not_found.should be_empty
  end
  
  failure_message_for_should do |actual|
    "Unable to find PSC participants for #{@not_found.inspect}"
  end
end
