#!/usr/bin/env ruby

require 'test/unit'
require 'ruby-prof'


# --  Tests ----
class ExcludeThreadsTest < Test::Unit::TestCase
  def test_exclude_threads

    def thread1_proc
      sleep(0.5)
      sleep(2)
    end

    def thread2_proc
      sleep(0.5)
      sleep(2)
    end

    thread1 = Thread.new do
      thread1_proc
    end

    thread2 = Thread.new do
      thread2_proc
    end

    RubyProf::exclude_threads = [ thread2 ]

    RubyProf.start

    thread1.join
    thread2.join

    result = RubyProf.stop

    RubyProf::exclude_threads = nil

    assert_equal(2, result.threads.length)

    output = Array.new
    result.threads.each do | thread_id, methods |
      methods.each do | m |
        if m.full_name.index("ExcludeThreadsTest#thread") == 0
          output.push(m.full_name)
        end
      end
    end

    assert_equal(1, output.length)
    assert_equal("ExcludeThreadsTest#thread1_proc", output[0])
  end
end
