# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::CronParser do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.new' do
    it 'parses a valid cron expression' do
      expr = described_class.new('*/5 * * * *')
      expect(expr).to be_a(described_class::Expression)
    end

    it 'raises Error for invalid expression' do
      expect { described_class.new('invalid') }.to raise_error(described_class::Error)
    end

    it 'raises Error for too few fields' do
      expect { described_class.new('* * *') }.to raise_error(described_class::Error)
    end

    it 'raises Error for too many fields' do
      expect { described_class.new('* * * * * *') }.to raise_error(described_class::Error)
    end
  end

  describe Philiprehberger::CronParser::Expression do
    describe '#matches?' do
      it 'matches every minute with * * * * *' do
        expr = described_class.new('* * * * *')
        time = Time.new(2026, 3, 22, 10, 30, 0)
        expect(expr.matches?(time)).to be true
      end

      it 'matches specific minute' do
        expr = described_class.new('30 * * * *')
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 30, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 15, 0))).to be false
      end

      it 'matches specific hour and minute' do
        expr = described_class.new('0 9 * * *')
        expect(expr.matches?(Time.new(2026, 3, 22, 9, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 0, 0))).to be false
      end

      it 'matches step expressions' do
        expr = described_class.new('*/15 * * * *')
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 15, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 30, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 7, 0))).to be false
      end

      it 'matches range expressions' do
        expr = described_class.new('0 9-17 * * *')
        expect(expr.matches?(Time.new(2026, 3, 22, 9, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 17, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 8, 0, 0))).to be false
      end

      it 'matches list expressions' do
        expr = described_class.new('0 9,12,17 * * *')
        expect(expr.matches?(Time.new(2026, 3, 22, 9, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 12, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 22, 10, 0, 0))).to be false
      end

      it 'matches weekday field' do
        expr = described_class.new('0 9 * * 1') # Monday
        monday = Time.new(2026, 3, 23, 9, 0, 0) # 2026-03-23 is Monday
        sunday = Time.new(2026, 3, 22, 9, 0, 0) # 2026-03-22 is Sunday
        expect(expr.matches?(monday)).to be true
        expect(expr.matches?(sunday)).to be false
      end
    end

    describe '#next' do
      it 'finds the next occurrence' do
        expr = described_class.new('0 9 * * *')
        from = Time.new(2026, 3, 22, 8, 0, 0)
        result = expr.next(from: from)
        expect(result).to eq(Time.new(2026, 3, 22, 9, 0, 0))
      end

      it 'advances to next day if past the time' do
        expr = described_class.new('0 9 * * *')
        from = Time.new(2026, 3, 22, 10, 0, 0)
        result = expr.next(from: from)
        expect(result).to eq(Time.new(2026, 3, 23, 9, 0, 0))
      end

      it 'finds next occurrence for step expressions' do
        expr = described_class.new('*/15 * * * *')
        from = Time.new(2026, 3, 22, 10, 1, 0)
        result = expr.next(from: from)
        expect(result).to eq(Time.new(2026, 3, 22, 10, 15, 0))
      end
    end

    describe '#prev' do
      it 'finds the previous occurrence' do
        expr = described_class.new('0 9 * * *')
        from = Time.new(2026, 3, 22, 10, 0, 0)
        result = expr.prev(from: from)
        expect(result).to eq(Time.new(2026, 3, 22, 9, 0, 0))
      end

      it 'goes back to previous day if before the time' do
        expr = described_class.new('0 9 * * *')
        from = Time.new(2026, 3, 22, 8, 0, 0)
        result = expr.prev(from: from)
        expect(result).to eq(Time.new(2026, 3, 21, 9, 0, 0))
      end
    end

    describe '#next_n' do
      it 'returns N next occurrences' do
        expr = described_class.new('0 9 * * *')
        from = Time.new(2026, 3, 22, 8, 0, 0)
        results = expr.next_n(3, from: from)
        expect(results.size).to eq(3)
        expect(results[0]).to eq(Time.new(2026, 3, 22, 9, 0, 0))
        expect(results[1]).to eq(Time.new(2026, 3, 23, 9, 0, 0))
        expect(results[2]).to eq(Time.new(2026, 3, 24, 9, 0, 0))
      end
    end

    describe '#human_readable' do
      it 'describes every-minute cron' do
        expr = described_class.new('* * * * *')
        expect(expr.human_readable).to include('every minute')
      end

      it 'describes specific time' do
        expr = described_class.new('30 9 * * *')
        result = expr.human_readable
        expect(result).to include('at minute 30')
        expect(result).to include('at hour 9')
      end
    end
  end

  describe Philiprehberger::CronParser::Field do
    it 'parses wildcard' do
      field = described_class.new('*', min: 0, max: 59)
      expect(field.values).to eq((0..59).to_a)
    end

    it 'parses step' do
      field = described_class.new('*/10', min: 0, max: 59)
      expect(field.values).to eq([0, 10, 20, 30, 40, 50])
    end

    it 'parses range' do
      field = described_class.new('1-5', min: 0, max: 59)
      expect(field.values).to eq([1, 2, 3, 4, 5])
    end

    it 'parses range with step' do
      field = described_class.new('0-30/10', min: 0, max: 59)
      expect(field.values).to eq([0, 10, 20, 30])
    end

    it 'parses list' do
      field = described_class.new('1,15,30', min: 0, max: 59)
      expect(field.values).to eq([1, 15, 30])
    end

    it 'parses single value' do
      field = described_class.new('5', min: 0, max: 59)
      expect(field.values).to eq([5])
    end

    it 'raises for out-of-range value' do
      expect do
        described_class.new('60', min: 0, max: 59)
      end.to raise_error(Philiprehberger::CronParser::Error)
    end

    it 'raises for invalid expression' do
      expect do
        described_class.new('abc', min: 0, max: 59)
      end.to raise_error(Philiprehberger::CronParser::Error)
    end

    it 'raises for zero step' do
      expect do
        described_class.new('*/0', min: 0, max: 59)
      end.to raise_error(Philiprehberger::CronParser::Error)
    end

    it 'raises for inverted range' do
      expect do
        described_class.new('10-5', min: 0, max: 59)
      end.to raise_error(Philiprehberger::CronParser::Error)
    end

    it 'parses list with ranges combined' do
      field = described_class.new('1-3,7,10-12', min: 0, max: 59)
      expect(field.values).to eq([1, 2, 3, 7, 10, 11, 12])
    end

    it 'deduplicates overlapping ranges' do
      field = described_class.new('1-5,3-7', min: 0, max: 59)
      expect(field.values).to eq([1, 2, 3, 4, 5, 6, 7])
    end

    describe '#matches?' do
      it 'returns true for value in the set' do
        field = described_class.new('5,10,15', min: 0, max: 59)
        expect(field.matches?(10)).to be true
      end

      it 'returns false for value not in the set' do
        field = described_class.new('5,10,15', min: 0, max: 59)
        expect(field.matches?(7)).to be false
      end
    end
  end

  describe Philiprehberger::CronParser::Expression do
    describe '#matches? (extended)' do
      it 'matches specific day of month' do
        expr = described_class.new('0 0 15 * *')
        expect(expr.matches?(Time.new(2026, 3, 15, 0, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 3, 14, 0, 0, 0))).to be false
      end

      it 'matches specific month' do
        expr = described_class.new('0 0 1 12 *')
        expect(expr.matches?(Time.new(2026, 12, 1, 0, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 11, 1, 0, 0, 0))).to be false
      end

      it 'matches midnight exactly' do
        expr = described_class.new('0 0 * * *')
        expect(expr.matches?(Time.new(2026, 1, 1, 0, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 1, 1, 0, 1, 0))).to be false
      end

      it 'matches end of day (23:59)' do
        expr = described_class.new('59 23 * * *')
        expect(expr.matches?(Time.new(2026, 6, 15, 23, 59, 0))).to be true
      end

      it 'matches weekday range (Mon-Fri)' do
        expr = described_class.new('0 9 * * 1-5')
        monday = Time.new(2026, 3, 23, 9, 0, 0)
        saturday = Time.new(2026, 3, 28, 9, 0, 0)
        expect(expr.matches?(monday)).to be true
        expect(expr.matches?(saturday)).to be false
      end

      it 'matches Sunday as weekday 0' do
        expr = described_class.new('0 9 * * 0')
        sunday = Time.new(2026, 3, 22, 9, 0, 0)
        expect(expr.matches?(sunday)).to be true
      end

      it 'matches combined range and step in hour field' do
        expr = described_class.new('0 0-12/3 * * *')
        expect(expr.matches?(Time.new(2026, 1, 1, 0, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 1, 1, 3, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 1, 1, 6, 0, 0))).to be true
        expect(expr.matches?(Time.new(2026, 1, 1, 1, 0, 0))).to be false
      end
    end

    describe '#next (extended)' do
      it 'finds next occurrence for specific weekday' do
        expr = described_class.new('0 9 * * 5') # Friday
        from = Time.new(2026, 3, 22, 10, 0, 0) # Sunday
        result = expr.next(from: from)
        expect(result.wday).to eq(5)
        expect(result.hour).to eq(9)
        expect(result.min).to eq(0)
      end

      it 'finds next midnight' do
        expr = described_class.new('0 0 * * *')
        from = Time.new(2026, 3, 22, 23, 30, 0)
        result = expr.next(from: from)
        expect(result).to eq(Time.new(2026, 3, 23, 0, 0, 0))
      end
    end

    describe '#next_n (extended)' do
      it 'returns empty array for count 0' do
        expr = described_class.new('0 9 * * *')
        results = expr.next_n(0, from: Time.new(2026, 3, 22, 8, 0, 0))
        expect(results).to eq([])
      end

      it 'returns 1 result for count 1' do
        expr = described_class.new('0 9 * * *')
        results = expr.next_n(1, from: Time.new(2026, 3, 22, 8, 0, 0))
        expect(results.size).to eq(1)
        expect(results[0]).to eq(Time.new(2026, 3, 22, 9, 0, 0))
      end
    end

    describe '#human_readable (extended)' do
      it 'describes a complex expression' do
        expr = described_class.new('*/10 9-17 * * 1-5')
        result = expr.human_readable
        expect(result).to be_a(String)
        expect(result.length).to be > 0
      end
    end

    describe '#expression' do
      it 'returns the original expression string' do
        expr = described_class.new('*/5 * * * *')
        expect(expr.expression).to eq('*/5 * * * *')
      end

      it 'strips whitespace from expression' do
        expr = described_class.new('  */5  *  *  *  *  ')
        expect(expr.expression).to eq('*/5  *  *  *  *')
      end
    end
  end
end
