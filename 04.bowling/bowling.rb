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

    frames.each.with_index(0) do |frame_scores, index|
      bonus_score = calculate_bonus_score(frame_scores, index)
      @total_score += (frame_scores.sum + bonus_score)
    end
  end

  private

  def next_frame_scores(index)
    frames[index + 1]
  end

  def before_frame_scores(index)
    frames[index - 1]
  end

  def calculate_bonus_score(frame_scores, index)
    # 最初のフレームは、ボーナススコアが0
    return 0 if index < 1

    # ストライク
    if before_frame_scores(index).first == 10
      # 最終フレームでの、ダブルストライクの場合
      # => 最後のフレームは、ストライクの場合投球数が増える関係で、ストライクの時のボーナススコアの計算方法が異なる
      return frame_scores.first + frame_scores.second.to_i if frame_scores.first == 10 && index >= 9

      # 2連続ストライクの場合
      return frame_scores.first + next_frame_scores(index).first if frame_scores.first == 10

      # 前回がストライクの場合（フレーム計算時に0をdeleteしているので、2投目以降がnilの可能性がある > to_iを入れて対策）
      return frame_scores.first + frame_scores.second.to_i
    end

    # スペア
    return frame_scores.first if before_frame_scores(index).sum == 10

    0
  end

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
    throws_by_splitted.each_with_object([]) do |frame_throws, array|
      if array.size < 10
        # 最終フレームの一投目がストライクの場合を考慮
        frame_throws.delete(0) if array.size >= 9
        array << frame_throws
        next
      end

      frame_throws.delete(0)
      array.last.concat(frame_throws)
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
