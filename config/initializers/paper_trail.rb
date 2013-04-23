# -*- coding: utf-8 -*-

require 'active_record/base'
require 'paper_trail'

# Everything should have a paper trail.  Except the things that shouldn't.
ActiveSupport.on_load(:active_record) do
  class << self
    PaperTrailExclusions = %w(
      EventTypeOrder
      Version
    )

    # Invoking `has_paper_trail` on AR::Base directly doesn't work.
    def inherited_with_auto_paper_trail(child)
      inherited_without_auto_paper_trail(child)
      child.send :has_paper_trail unless PaperTrailExclusions.include?(child.to_s)
    end

    alias_method_chain :inherited, :auto_paper_trail
  end
end
