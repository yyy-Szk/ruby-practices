#! /usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

class String
  def invert_color
    "\e[7m#{self}\e[0m"
  end
end

class Date
  def beginning_of_month
    self.class.new(year, month)
  end

  def end_of_month
    self.class.new(year, month, -1)
  end
end

today = Date.today
calendar_width = 20

opt = OptionParser.new
month_option = nil
year_option = nil

opt.on('-m MONTH') { |v| month_option = v.to_i }
opt.on('-y YEAR') { |v| year_option = v.to_i }
opt.parse!(ARGV)

target_date = Date.new(year_option || today.year, month_option || today.month)
date_range = target_date.beginning_of_month..target_date.end_of_month

# 出力担当
puts "#{target_date.month}月 #{target_date.year}".center(calendar_width)
puts '日 月 火 水 木 金 土'
# 月初の曜日調整
print ' ' * (3 * date_range.first.wday)

date_range.each.with_index(1) do |date, index|
  day = date.day.to_s.rjust(2)
  print date == today ? day.invert_color : day
  print ' ' # 日付間の空白

  puts if date.saturday?
end
