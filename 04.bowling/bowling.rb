#! /usr/bin/env ruby
# frozen_string_literal: true

class Array
  def second
    self[1]
  end
end

class BowlingScoreCalculator
  attr_reader :total_score, :throws

  def initialize(throws)
    @throws = throws
  end

  def calculate
    # total_score は 計算するまで nil にしたいのでここで入れる
    @total_score = 0
    bonus_type = nil

    frames.each.with_index(1) do |frame_scores, frame_count|
      bonus_score = calculate_bonus_score(frame_scores, bonus_type, frame_count)
      # 次のフレームに適用するボーナスタイプを算出
      bonus_type = check_next_frame_bonus_type(frame_scores, bonus_type)

      @total_score += (frame_scores.sum + bonus_score)
    end
  end

  private

  def check_next_frame_bonus_type(frame_scores, bonus_type)
    if frame_scores.first == 10
      case bonus_type
      when :strike, :double_strike then :double_strike
      else :strike
      end
    elsif frame_scores.sum == 10
      :spare
    end
  end

  def calculate_bonus_score(frame_scores, bonus_type, _frame_count)
    first_throw, second_throw = frame_scores
    case bonus_type
    when :spare then first_throw
    when :strike then first_throw + second_throw
    when :double_strike then first_throw * 2 + second_throw
    else 0
    end
  end

  def frames
    strike = 'X'

    # 2投ごとに分ける（この時点ではフレーム数が10を超えている）
    throws_by_splitted = throws.split(',').each_with_object([]) do |v, array|
      if v == strike
        array.push(10, 0)
      else
        array.push(v.to_i)
      end
    end.each_slice(2).to_a

    # 最終フレームを最適化する（フレーム数が10になるように調整）
    throws_by_splitted.each_with_object([]) do |v, array|
      if array.size < 9
        array << v
        next
      end

      first_throw, second_throw = v
      array << [] if array[9].nil?
      array.last << first_throw
      array.last << second_throw if second_throw && second_throw != 0
    end
  end
end

# 結果は第一引数に渡される
throws = ARGV[0]

# 入力忘れ用
if throws.nil?
  puts '第一引数に結果を渡してください。'
  return
end

bowling_score_calculator = BowlingScoreCalculator.new(throws)
bowling_score_calculator.calculate

puts bowling_score_calculator.total_score
