# frozen_string_literal: true

require_relative 'field'

module Philiprehberger
  module CronParser
    # Represents a parsed 5-field cron expression
    class Expression
      FIELD_RANGES = {
        minute: { min: 0, max: 59 },
        hour: { min: 0, max: 23 },
        day: { min: 1, max: 31 },
        month: { min: 1, max: 12 },
        weekday: { min: 0, max: 6 }
      }.freeze

      WEEKDAY_NAMES = { 'minute' => nil, 'hour' => nil, 'day' => nil, 'month' => nil,
                        'weekday' => nil }.freeze

      HUMAN_LABELS = {
        minute: 'minute',
        hour: 'hour',
        day: 'day of month',
        month: 'month',
        weekday: 'day of week'
      }.freeze

      # @return [String] the original expression
      attr_reader :expression

      # @param expr [String] a 5-field cron expression
      # @raise [Error] if the expression is invalid
      def initialize(expr)
        @expression = expr.strip
        parts = @expression.split(/\s+/)
        raise Error, "Expected 5 fields, got #{parts.size}: #{@expression}" unless parts.size == 5

        @fields = {}
        FIELD_RANGES.each_with_index do |(name, range), index|
          @fields[name] = Field.new(parts[index], **range)
        end
      end

      # Check if a given time matches this cron expression
      #
      # @param time [Time] the time to check
      # @return [Boolean]
      def matches?(time)
        @fields[:minute].matches?(time.min) &&
          @fields[:hour].matches?(time.hour) &&
          @fields[:day].matches?(time.day) &&
          @fields[:month].matches?(time.month) &&
          @fields[:weekday].matches?(time.wday)
      end

      # Calculate the next occurrence after the given time
      #
      # @param from [Time] the starting time
      # @return [Time] the next matching time
      # @raise [Error] if no match found within 4 years
      def next(from: Time.now)
        find_occurrence(from, direction: :forward)
      end

      # Calculate the previous occurrence before the given time
      #
      # @param from [Time] the starting time
      # @return [Time] the previous matching time
      # @raise [Error] if no match found within 4 years
      def prev(from: Time.now)
        find_occurrence(from, direction: :backward)
      end

      # Calculate the next N occurrences after the given time
      #
      # @param count [Integer] the number of occurrences to find
      # @param from [Time] the starting time
      # @return [Array<Time>] the next N matching times
      def next_n(count, from: Time.now)
        results = []
        current = from
        count.times do
          current = self.next(from: current)
          results << current
          current += 60
        end
        results
      end

      # Return a human-readable description of the expression
      #
      # @return [String]
      def human_readable
        parts = []
        parts << minute_description
        parts << hour_description
        parts << day_description
        parts << month_description
        parts << weekday_description
        parts.compact.join(', ')
      end

      private

      def find_occurrence(from, direction:)
        step = direction == :forward ? 60 : -60
        current = round_to_minute(from) + step
        limit = 4 * 365 * 24 * 60 # 4 years in minutes

        limit.times do
          return current if matches?(current)

          current += step
        end

        raise Error, 'No matching time found within 4 years'
      end

      def round_to_minute(time)
        Time.new(time.year, time.month, time.day, time.hour, time.min, 0, time.utc_offset)
      end

      def minute_description
        describe_field(:minute, 'every minute', 'at minute')
      end

      def hour_description
        describe_field(:hour, nil, 'at hour')
      end

      def day_description
        describe_field(:day, nil, 'on day')
      end

      def month_description
        describe_field(:month, nil, 'in month')
      end

      def weekday_description
        describe_field(:weekday, nil, 'on weekday')
      end

      def describe_field(name, wildcard_text, prefix)
        field = @fields[name]
        range = FIELD_RANGES[name]
        all_values = (range[:min]..range[:max]).to_a

        if field.values == all_values
          wildcard_text
        else
          "#{prefix} #{field.values.join(',')}"
        end
      end
    end
  end
end
