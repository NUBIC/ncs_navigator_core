require 'spec_helper'
require 'nokogiri'

###
# This set of specs describes properties of the PSC template. It relies on a
# snapshot of the current template being maintained in spec/fixtures/psc.
# A snapshot is the result from either of these resources in PSC's API:
#   * studies/{study-identifier}/template/current.xml (for last released)
#   * studies/{study-identifier}/template/development.xml (for current development, if any)

describe 'PSC template' do
  let(:template_xml) {
    Nokogiri::XML(File.read(
      File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__)))
  }

  let(:all_labels) {
    template_xml.css('planned-activity label').collect { |l| l['name'] }
  }

  describe 'test setup' do
    it 'finds the labels' do
      all_labels.should_not == []
    end

    it 'finds only labels' do
      all_labels.compact.should_not be_empty
    end
  end

  describe 'event label set' do
    let(:prefix) { %r{^event:} }

    let(:events_named_in_labels) {
      all_labels.select { |l| l =~ prefix }.collect { |n| n.sub(prefix, '') }
    }

    let(:event_types_from_mdes) {
      NcsNavigatorCore.mdes.types.
        find { |t| t.name == 'event_type_cl1' }.
        code_list.collect { |cl| cl.label.strip.downcase.gsub(/\s+/, '_') }
    }

    let(:event_labels_by_segment_by_day) {
      template_xml.css('study-segment').inject({}) do |segments, seg|
        segments[seg['name']] = seg.css('planned-activity').inject({}) do |by_day, pa|
          one_day = (by_day[pa['day'].to_i] ||= [])
          pa.css('label').collect { |l| l['name'] }.select { |n| n =~ prefix }.each do |event|
            # uniq! instead of a set because sets don't behave like
            # arrays in all situations (e.g., no #flatten)
            (one_day << event).uniq!
          end
          by_day
        end
        segments
      end
    }


    it 'covers only known event types' do
      (events_named_in_labels - event_types_from_mdes).uniq.should == []
    end

    it 'schedules any given event type only once per day per segment' do
      errors = []
      event_labels_by_segment_by_day.each do |segment_name, event_labels_by_day|
        event_labels_by_day.each do |day_1, event_labels_1|
          event_labels_by_day.each do |day_2, event_labels_2|
            next if day_2 <= day_1
            overlap = (event_labels_1 & event_labels_2)
            unless overlap.empty?
              errors << "#{overlap.to_a.join(' and ')} occur#{'s' if overlap.size == 1} on both #{day_1} and #{day_2} in #{segment_name.inspect}."
            end
          end
        end
      end
      errors.should == []
    end

    # This invariant is required by the importer, which needs to be
    # able to take an event and do one of these:
    #
    #   - Find an existing segment with a corresponding event
    #   - Find a single corresponding segment to schedule
    #   - Defer the event until the first condition is true
    #
    # It special-cases the birth event by lo vs. hi, so this test
    # special-cases it also.
    it 'schedules any event that occurs on multiple days alongside an event that occurs on only one day' do
      pending 'Until Child Consent segment is removed'

      multiply_scheduled_event_and_counts = event_labels_by_segment_by_day.inject({}) do |counts, (segment_name, event_labels_by_day)|
        event_labels_by_day.each do |day, event_labels|
          event_labels.each { |event| counts[event] = (counts[event] || 0) + 1 }
        end
        counts
      end.select { |event, count| count > 1 }

      # special case for Hi-Lo birth; see above
      if template_xml.css('study-snapshot').first['assigned-identifier'] =~ /Hi-Lo/
        multiply_scheduled_event_and_counts -= [['event:birth', 2]]
      end

      multiply_scheduled_events = multiply_scheduled_event_and_counts.collect { |e, c| e }

      problems = event_labels_by_segment_by_day.collect do |segment_name, event_labels_by_day|
        multiply_scheduled_events.collect do |mult_event|
          event_labels_by_day.
            select { |day, events| events.include?(mult_event) }.
            select { |day, events| (events - multiply_scheduled_events).empty? }.
            collect  { |day, _| "#{mult_event} occurs without any one-day events on day #{day} of #{segment_name}" }
        end
      end.flatten.compact

      problems.should == []
    end
  end

  describe 'instrument label set' do
    let(:prefix) { %r{^instrument:} }

    let(:instruments_named_in_labels) {
      all_labels.select { |l| l =~ prefix }.collect { |n| n.sub(prefix, '') }.uniq
    }

    let(:instruments_from_map) {
      INSTRUMENT_EVENT_CONFIG.collect { |ie| ie['filename'].downcase }.uniq
    }

    it 'covers only mapped instruments' do
      (instruments_named_in_labels - instruments_from_map).uniq.should == []
    end
  end
end
