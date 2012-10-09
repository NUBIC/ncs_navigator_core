module Field
  ##
  # This module is intended for private use by {Field::Merge}.
  #
  # At present, {#link} establishes {ParticipantPersonLink}s.  In future it
  # will also establish {ContactLink}s.
  module Linking
    def link
      true
    end
  end
end
