#! /usr/bin/env ruby

require 'date'
require 'optparse'

# これモンキーパッチってやつでもっといい感じに書けるのでは？ > Dateクラス
def beginning_of_month(date)
  Date.new(date.year, date.month, 1)
end

def end_of_month(date)
  if date.month == 12
    year = date.year + 1
    month = 1
  else
    year = date.year
    month = date.month + 1
  end
  
  Date.new(year, month, 1) - 1
end

today = Date.today
calendar_width = 20

opt = OptionParser.new
month_option = nil
year_option = nil
# オプションのバリデーションもするか？
opt.on("-m MONTH") { |v| month_option = v.to_i }
opt.on("-y YEAR") { |v| year_option = v.to_i }
opt.parse!(ARGV)

target_date = Date.new(year_option || today.year, month_option || today.month, 1)
date_range = beginning_of_month(target_date)..end_of_month(target_date)

puts "#{target_date.month}月 #{target_date.year}".center(calendar_width)
puts "日 月 火 水 木 金 土"

date_range.each.with_index(1) do |date, index|
  if index == 1
    print " " * (3 * date.wday)
  end
  print date.day.to_s.rjust(2) + " "
  puts if date.saturday?
end

