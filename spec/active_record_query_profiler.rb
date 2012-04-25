class ActiveRecordQueryProfiler
  attr_reader :query_events
  attr_accessor :start, :end

  def self.register(spec_config)
    # If I don't use a global, only the stats for the last spec are reported.
    return if $qp
    $qp = self.new
    $qp.subscribe_to_queries
    $qp.start = Time.now

    spec_config.after(:suite) do
      $qp.end = Time.now
      $qp.print_slow_queries
    end
  end

  def initialize
    @query_events = {}
  end

  def subscribe_to_queries
    ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)

      (query_events[event.payload[:sql]] ||= []) << event
    end
  end

  def print_slow_queries
    [:frequency, :total_duration, :average_duration].each do |kind|
      print_top_ten(kind)
    end

    $stderr.puts "%d types of queries executed." % query_events.size

    $stderr.puts "Database took %.1f ms out of %.1f ms total (%.1f%%)." % [
      total_duration,
      elapsed_ms,
      total_duration / elapsed_ms
    ]
  end

  def print_top_ten(kind)
    ordered_summaries = self.send("queries_by_#{kind}")
    header = "=== Top queries by #{kind.to_s.humanize} ==="
    $stderr.puts '=' * header.size
    $stderr.puts header
    $stderr.puts '=' * header.size

    ordered_summaries[0..9].each do |summary|
      $stderr.puts "- #{summary[:sql]}"
      $stderr.puts "  => Invoked %d time(s) taking %.1f ms; average %.1f ms.\n" % [
        summary[:count], summary[:total_duration],
        summary[:total_duration] / summary[:count]
      ]
    end
    $stderr.puts
  end

  def elapsed_ms
    (@end - @start) * 1000
  end

  def total_duration
    query_summaries.inject(0) { |sum, summary| sum + summary[:total_duration] }
  end

  def queries_by_frequency
    query_summaries.sort_by { |summary| -1 * summary[:count] }
  end

  def queries_by_total_duration
    query_summaries.sort_by { |summary| -1 * summary[:total_duration] }
  end

  def queries_by_average_duration
    query_summaries.sort_by { |summary| -1 * summary[:total_duration] / summary[:count] }
  end

  # Unfortunately, the after(:all) is running after every
  # file. Memoizing here does not work.
  def query_summaries
    query_events.collect { |sql, events|
      {
        :sql => sql,
        :count => events.size,
        :total_duration => events.inject(0) { |sum, e| sum + e.duration }
      }
    }
  end
end
