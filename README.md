# philiprehberger-cron_parser

[![Tests](https://github.com/philiprehberger/rb-cron-parser/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-cron-parser/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-cron_parser.svg)](https://rubygems.org/gems/philiprehberger-cron_parser)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-cron-parser)](https://github.com/philiprehberger/rb-cron-parser/commits/main)

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

### Named Months and Weekdays

Use named months (JAN-DEC) and weekdays (SUN-SAT) in cron expressions. Names are case-insensitive and work in ranges and lists.

```ruby
Philiprehberger::CronParser.new('0 0 1 JAN *')         # first of January
Philiprehberger::CronParser.new('0 0 1 JAN-MAR *')     # first of Jan-Mar
Philiprehberger::CronParser.new('0 0 * * MON')         # every Monday
Philiprehberger::CronParser.new('0 0 * * MON-FRI')     # weekdays
Philiprehberger::CronParser.new('0 0 * * MON,WED,FRI') # specific days
Philiprehberger::CronParser.new('0 0 * * 1,WED,5')     # mixed numeric and named
```

### Validation

```ruby
Philiprehberger::CronParser.valid?('*/5 * * * *')  # => true
Philiprehberger::CronParser.valid?('60 * * * *')   # => false

result = Philiprehberger::CronParser.validate('60 25 * * *')
result[:valid]   # => false
result[:errors]  # => ["minute field: Value 60 out of range (0-59)", "hour field: Value 25 out of range (0-23)"]
```

### Supported Syntax

Standard 5-field cron expressions (minute hour day month weekday):

```ruby
Philiprehberger::CronParser.new('* * * * *')       # every minute
Philiprehberger::CronParser.new('*/5 * * * *')     # every 5 minutes
Philiprehberger::CronParser.new('0 9-17 * * *')    # hourly 9am-5pm
Philiprehberger::CronParser.new('0 9,12,17 * * *') # specific hours
Philiprehberger::CronParser.new('0 0 1 * *')       # first of month
Philiprehberger::CronParser.new('0 0 1 JAN-MAR *') # named months
Philiprehberger::CronParser.new('0 9 * * MON-FRI') # named weekdays
```

## API

| Method | Description |
|--------|-------------|
| `CronParser.new(expr)` | Parse a 5-field cron expression |
| `CronParser.valid?(expr)` | Check if expression is valid (returns boolean) |
| `CronParser.validate(expr)` | Validate with structured field-level errors |
| `Expression#next(from:)` | Calculate the next matching time |
| `Expression#prev(from:)` | Calculate the previous matching time |
| `Expression#next_n(n, from:)` | Calculate the next N matching times |
| `Expression#matches?(time)` | Check if a time matches the expression |
| `Expression#human_readable` | Human-readable description of the expression |
| `Expression#description` | Alias for `human_readable` |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-cron-parser)

🐛 [Report issues](https://github.com/philiprehberger/rb-cron-parser/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-cron-parser/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
