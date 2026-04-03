# frozen_string_literal: true

module Philiprehberger
  module CronParser
    # Parses a single cron field (minute, hour, day, month, weekday)
    class Field
      MONTH_NAMES = {
        'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4,
        'MAY' => 5, 'JUN' => 6, 'JUL' => 7, 'AUG' => 8,
        'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12
      }.freeze

      WEEKDAY_NAMES = {
        'SUN' => 0, 'MON' => 1, 'TUE' => 2, 'WED' => 3,
        'THU' => 4, 'FRI' => 5, 'SAT' => 6
      }.freeze

      # @return [Array<Integer>] the expanded set of valid values
      attr_reader :values

      # @param expr [String] the field expression (e.g. "*/5", "1,3,5", "1-10")
      # @param min [Integer] the minimum valid value
      # @param max [Integer] the maximum valid value
      # @param names [Hash, nil] optional name-to-value mapping for this field
      # @raise [Error] if the expression is invalid
      def initialize(expr, min:, max:, names: nil)
        @min = min
        @max = max
        @names = names
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

      def resolve_name(token)
        return token.to_i if token.match?(/\A\d+\z/)

        raise Error, "Invalid cron field expression: #{token}" unless @names

        value = @names[token.upcase]
        raise Error, "Invalid name '#{token}' for this field" unless value

        value
      end

      def parse_part(part)
        case part
        when '*'
          (@min..@max).to_a
        when %r{\A\*/(\d+)\z}
          step = Regexp.last_match(1).to_i
          raise Error, "Invalid step: #{step}" if step.zero?

          (@min..@max).step(step).to_a
        when %r{\A([a-zA-Z0-9]+)-([a-zA-Z0-9]+)(?:/(\d+))?\z}
          range_start = resolve_name(Regexp.last_match(1))
          range_end = resolve_name(Regexp.last_match(2))
          step = Regexp.last_match(3)&.to_i || 1
          validate_range!(range_start, range_end)
          raise Error, "Invalid step: #{step}" if step.zero?

          (range_start..range_end).step(step).to_a
        when /\A\d+\z/
          value = part.to_i
          validate_value!(value)
          [value]
        when /\A[a-zA-Z]+\z/
          value = resolve_name(part)
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
        return if value.between?(@min, @max)

        raise Error, "Value #{value} out of range (#{@min}-#{@max})"
      end
    end
  end
end
