module NcsNavigator::Core::Spec::Matchers
  ##
  # An RSpec custom matcher which counts the ActiveRecord queries made in a
  # block. If they are over a given threshold, it fails the example and lists
  # the queries.
  #
  # Inspired by http://stackoverflow.com/a/13423584/153896
  class QueryCountMatcher
    IGNORED_NOTIFICATIONS = %w(CACHE SCHEMA)

    attr_reader :query_count_threshold

    def initialize(query_count_threshold)
      @query_count_threshold = query_count_threshold
    end

    def matches?(actual_block)
      capture_queries(&actual_block)
      queries.size > @query_count_threshold
    end

    def capture_queries(&block)
      # TODO: after updating to Rails 3.2, this whole method can be simplified to:
      # ActiveSupport::Notifications.subscribed(self, 'sql.active_record', &block)
      begin
        ActiveSupport::Notifications.subscribe('sql.active_record', self)
        yield
      ensure
        ActiveSupport::Notifications.unsubscribe(self)
      end
    end
    private :capture_queries

    def failure_message_for_should
      message('Fewer')
    end

    def failure_message_for_should_not
      message('More')
    end

    def message(modifier)
      "#{modifier} than expected number of queries issued (#{queries.size}, not #{query_count_threshold})".tap do |msg|
        if queries.size > 0
          msg << ":\n* " << queries.join("\n* ")
        else
          msg << '.'
        end
      end
    end
    private :message

    # @private
    # Allows an instance of this class to act as a notification subscriber
    # directly.
    def call(_, _, _, _, payload)
      unless IGNORED_NOTIFICATIONS.include?(payload[:name])
        queries << payload[:sql]
      end
    end

    def queries
      @queries ||= []
    end
  end

  def execute_more_queries_than(limit)
    QueryCountMatcher.new(limit)
  end
end
