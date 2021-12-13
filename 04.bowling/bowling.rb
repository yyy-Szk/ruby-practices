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
    case bonus_type
    when :spare then frame_scores.first
    when :strike then frame_scores.first + frame_scores.second.to_i # フレーム計算時に0をdeleteしているので、二投目以降がnilの可能性がある
    when :double_strike then frame_scores.first * 2 + frame_scores.second.to_i
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
    throws_by_splitted.each_with_object([]) do |_throw, array|
      if array.size < 10
        # 最終フレームの一投目がストライクの場合を考慮
        _throw.delete(0) if array.size >= 9
        array << _throw
        next
      end

      _throw.delete(0)
      array.last.concat(_throw)
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
