#! /usr/bin/env ruby
# frozen_string_literal: true

def split_flame(data)
  data.split(',').each_with_object([]) do |v, array|
    case v
    # ストライクの場合,一投目のスコアを10、二投目のスコアを0とする
    when 'X' then array.push(10, 0)
    else array.push(v.to_i)
    end
  end.each_slice(2).to_a
end

# 結果は第一引数に渡される
game_data = ARGV[0]

# 入力忘れ用
if game_data.nil? 
  puts "第一引数に結果を渡してください。"
  return
 end

p split_flame(game_data)
score = 0
is_strike = false
is_second_strike = false
is_spare = false
split_flame(game_data).each.with_index(1) do |data, index|
  first_throw, second_throw = data
  flame_score = data.sum

  # 二連続ストライクのみ、ラストフレーム以降に加算を行う可能性があるため外に出す
  score += first_throw if is_second_strike
  # ラストフレーム以降は、投球数が増えるだけで特別な処理はいらない = 9 投目の時点で全てのフラグをfalseにする
  unless index > 10
  # 前回の記録がspare/strikeかつ今回もstrikeの場合、一投目の点数を加算 / strikeの場合、フレーム全体の点数を加算
    score += first_throw if is_spare
    score += flame_score if is_strike
    # なんかメソッドにしたい
    if first_throw == 10
      is_second_strike = is_strike ? true : false
      is_strike = true
      is_spare = false
    elsif flame_score == 10
      is_spare = true
      is_second_strike = false
      is_strike = false
     else
      is_spare = false
      is_second_strike = false
      is_strike = false
    end
  else
    is_spare = false
    is_second_strike = false
    is_strike = false
  end

  score += flame_score
  # binding.irb
  # p 'score', score
end

puts score

