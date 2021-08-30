#! /usr/bin/env ruby

require 'date'

today = Date.today

def beginning_of_month(date)
  Date.new(date.year, date.month, 1)
end

def end_of_month(date)
  Date.new(date.year, date.month + 1, 1) - 1
end

puts "#{today.month}月 #{today.year}".center(20)
puts "日 月 火 水 木 金 土"

(beginning_of_month(today)..end_of_month(today)).each.with_index(1) do |date, index|
  if index == 1
    print " " * (3 * date.wday)
  end
  print date.day.to_s.rjust(2) + " "
  puts "\n" if date.saturday?
end

