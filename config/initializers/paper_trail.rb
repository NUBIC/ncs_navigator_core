# encoding: utf-8

require 'active_record/base'
require 'paper_trail'

# Everything should have a paper trail.
ActiveSupport.on_load(:active_record) do
  class << self
    # Invoking `has_paper_trail` on AR::Base directly doesn't work.
    def inherited_with_auto_paper_trail(child)
      child.send :has_paper_trail unless child.to_s == 'Version'
    end

    alias_method_chain :inherited, :auto_paper_trail
  end
end