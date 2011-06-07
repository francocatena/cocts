#!/usr/bin/env ruby
require 'test/unit'
require 'ruby-prof'

class MeasurementTest < Test::Unit::TestCase

  if RubyProf::MEMORY
    def test_memory_mode
      RubyProf::measure_mode = RubyProf::MEMORY
      assert_equal(RubyProf::MEMORY, RubyProf::measure_mode)
    end

    def test_memory
      t = RubyProf.measure_memory
      assert_kind_of Integer, t

      u = RubyProf.measure_memory
      assert(u >= t, [t, u].inspect)

      RubyProf::measure_mode = RubyProf::MEMORY
      result = RubyProf.profile {Array.new}
require 'rubygems'
require 'ruby-debug'
#debugger
      total = result.threads.values.first.inject(0) { |sum, m| sum + m.total_time }
      

      assert(total > 0, 'Should measure more than zero kilobytes of memory usage')
      p total
      assert_not_equal(0, total % 1, 'Should not truncate fractional kilobyte measurements')
    end
  end
end
