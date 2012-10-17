begin
  require 'psych'
  require 'psych/scalar_scanner'

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
rescue LoadError => e
  local_path = __FILE__[(Rails.root.to_s.size + 1)..-1]
  Rails.logger.warn("Could not load psych for #{local_path}. There may be something up with your ruby install.\nMessage: #{e}")
end
