#! /usr/bin/env ruby

require 'date'

today = Date.today
beginning_of_month = Date.new(today.year, today.month, 1)
end_of_month = Date.new(today.year, today.month + 1, 1) - 1

puts "#{today.month}月 #{today.year}".center(20)
puts "日 月 火 水 木 金 土"

(beginning_of_month..end_of_month).each.with_index(1) do |date, index|
  if index == 1
    print " " * (3 * date.wday)
  end
  print date.day.to_s.rjust(2) + " "
  puts "\n" if date.saturday?
end

