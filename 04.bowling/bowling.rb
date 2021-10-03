#! /usr/bin/env ruby
# frozen_string_literal: true

# 結果は第一引数に渡される
result = ARGV[0]

# 入力忘れ用
if result.nil? 
  puts "第一引数に結果を渡してください。"
  return
 end

score = 0
result.split(',').each do |data|
  score += data.to_i
end

puts score

