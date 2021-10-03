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
is_spare = false
result.split(',').each_slice(2).with_index(1) do |data, index|
  flame_score = data.sum(&:to_i)

  # 前回の記録がspareの場合、一投目の点数を加算
  # (ラストフレームを除く > ラストは投球数が増える)
  score += data[0].to_i if is_spare && index != 10
  score += flame_score

  p '=========='
  p score
  p '=========='

  is_spare = flame_score == 10 ? true : false
end

puts score

