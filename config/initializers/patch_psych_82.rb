require 'psych'
require 'psych/scalar_scanner'
puts "Loading #{__FILE__}"

# This monkey patch addresses https://github.com/tenderlove/psych/issues/82
# until there's a released version with a fix.

module Psych
  class ScalarScanner
    def parse_time_with_issue_82 *args
      begin
        parse_time_without_issue_82(*args)
      rescue ArgumentError
        args.first
      end
    end

    alias_method_chain :parse_time, :issue_82
  end
end
