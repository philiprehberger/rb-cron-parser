# frozen_string_literal: true

require_relative 'cron_parser/version'
require_relative 'cron_parser/field'
require_relative 'cron_parser/expression'

module Philiprehberger
  module CronParser
    class Error < StandardError; end

    # Parse a cron expression and return an Expression instance
    #
    # @param expr [String] a 5-field cron expression (minute hour day month weekday)
    # @return [Expression] the parsed expression
    # @raise [Error] if the expression is invalid
    def self.new(expr)
      Expression.new(expr)
    end
  end
end
