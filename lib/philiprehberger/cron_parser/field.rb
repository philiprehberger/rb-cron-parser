# frozen_string_literal: true

module Philiprehberger
  module CronParser
    # Parses a single cron field (minute, hour, day, month, weekday)
    class Field
      # @return [Array<Integer>] the expanded set of valid values
      attr_reader :values

      # @param expr [String] the field expression (e.g. "*/5", "1,3,5", "1-10")
      # @param min [Integer] the minimum valid value
      # @param max [Integer] the maximum valid value
      # @raise [Error] if the expression is invalid
      def initialize(expr, min:, max:)
        @min = min
        @max = max
        @values = parse(expr).sort.freeze
      end

      # Check if a value matches this field
      #
      # @param value [Integer] the value to check
      # @return [Boolean]
      def matches?(value)
        @values.include?(value)
      end

      private

      def parse(expr)
        result = []
        expr.split(',').each do |part|
          result.concat(parse_part(part.strip))
        end
        result.uniq
      end

      def parse_part(part)
        case part
        when '*'
          (@min..@max).to_a
        when /\A\*\/(\d+)\z/
          step = Regexp.last_match(1).to_i
          raise Error, "Invalid step: #{step}" if step.zero?

          (@min..@max).step(step).to_a
        when /\A(\d+)-(\d+)(?:\/(\d+))?\z/
          range_start = Regexp.last_match(1).to_i
          range_end = Regexp.last_match(2).to_i
          step = Regexp.last_match(3)&.to_i || 1
          validate_range!(range_start, range_end)
          raise Error, "Invalid step: #{step}" if step.zero?

          (range_start..range_end).step(step).to_a
        when /\A\d+\z/
          value = part.to_i
          validate_value!(value)
          [value]
        else
          raise Error, "Invalid cron field expression: #{part}"
        end
      end

      def validate_range!(range_start, range_end)
        validate_value!(range_start)
        validate_value!(range_end)
        raise Error, "Invalid range: #{range_start}-#{range_end}" if range_start > range_end
      end

      def validate_value!(value)
        return if value >= @min && value <= @max

        raise Error, "Value #{value} out of range (#{@min}-#{@max})"
      end
    end
  end
end
