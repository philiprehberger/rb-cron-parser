# frozen_string_literal: true

require_relative 'cron_parser/version'
require_relative 'cron_parser/field'
require_relative 'cron_parser/expression'

module Philiprehberger
  module CronParser
    class Error < StandardError; end

    FIELD_ORDER = %i[minute hour day month weekday].freeze

    # Parse a cron expression and return an Expression instance
    #
    # @param expr [String] a 5-field cron expression (minute hour day month weekday)
    # @return [Expression] the parsed expression
    # @raise [Error] if the expression is invalid
    def self.new(expr)
      Expression.new(expr)
    end

    # Check if a cron expression is valid without raising
    #
    # @param expr [String] a 5-field cron expression
    # @return [Boolean]
    def self.valid?(expr)
      Expression.new(expr)
      true
    rescue Error
      false
    end

    # Validate a cron expression and return structured errors
    #
    # @param expr [String] a 5-field cron expression
    # @return [Hash] { valid: true/false, errors: [String] }
    def self.validate(expr)
      errors = []
      stripped = expr.strip
      parts = stripped.split(/\s+/)

      unless parts.size == 5
        return { valid: false, errors: ["Expected 5 fields, got #{parts.size}"] }
      end

      FIELD_ORDER.each_with_index do |name, index|
        range = Expression::FIELD_RANGES[name]
        names_map = Expression::FIELD_NAMES_MAP[name]
        Field.new(parts[index], min: range[:min], max: range[:max], names: names_map)
      rescue Error => e
        errors << "#{name} field: #{e.message}"
      end

      { valid: errors.empty?, errors: errors }
    end
  end
end
