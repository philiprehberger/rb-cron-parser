# philiprehberger-cron_parser

[![Tests](https://github.com/philiprehberger/rb-cron-parser/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-cron-parser/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-cron_parser.svg)](https://rubygems.org/gems/philiprehberger-cron_parser)
[![License](https://img.shields.io/github/license/philiprehberger/rb-cron-parser)](LICENSE)

Cron expression parser for calculating next and previous occurrences

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-cron_parser"
```

Or install directly:

```bash
gem install philiprehberger-cron_parser
```

## Usage

```ruby
require "philiprehberger/cron_parser"

cron = Philiprehberger::CronParser.new('0 9 * * 1-5')
cron.next(from: Time.now)   # => next weekday at 9:00 AM
cron.prev(from: Time.now)   # => previous weekday at 9:00 AM
```

### Next Occurrences

```ruby
cron = Philiprehberger::CronParser.new('*/15 * * * *')
cron.next_n(5, from: Time.now)  # => next 5 quarter-hour times
```

### Matching

```ruby
cron = Philiprehberger::CronParser.new('0 9 * * *')
cron.matches?(Time.new(2026, 3, 22, 9, 0, 0))  # => true
cron.matches?(Time.new(2026, 3, 22, 10, 0, 0)) # => false
```

### Human-Readable Description

```ruby
cron = Philiprehberger::CronParser.new('30 9 * * 1-5')
cron.human_readable  # => "at minute 30, at hour 9, on weekday 1,2,3,4,5"
```

### Supported Syntax

Standard 5-field cron expressions (minute hour day month weekday):

```ruby
Philiprehberger::CronParser.new('* * * * *')       # every minute
Philiprehberger::CronParser.new('*/5 * * * *')     # every 5 minutes
Philiprehberger::CronParser.new('0 9-17 * * *')    # hourly 9am-5pm
Philiprehberger::CronParser.new('0 9,12,17 * * *') # specific hours
Philiprehberger::CronParser.new('0 0 1 * *')       # first of month
```

## API

| Method | Description |
|--------|-------------|
| `CronParser.new(expr)` | Parse a 5-field cron expression |
| `Expression#next(from:)` | Calculate the next matching time |
| `Expression#prev(from:)` | Calculate the previous matching time |
| `Expression#next_n(n, from:)` | Calculate the next N matching times |
| `Expression#matches?(time)` | Check if a time matches the expression |
| `Expression#human_readable` | Human-readable description of the expression |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
