#! /usr/bin/env ruby
# frozen_string_literal: true

class BowlingScoreCalculator
  attr_accessor :game_data
  attr_reader :total_score

  def initialize(game_data)
    @game_data = game_data
  end

  def calculate
    # total_score は 計算するまで nil にしたいのでここで入れる
    @total_score = 0
    bonus_type = nil

    game_data_splitted_by_frame.each.with_index(1) do |frame_scores, frame_count|
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

  def calculate_bonus_score(frame_scores, bonus_type, frame_count)
    first_throw = frame_scores.first

    case bonus_type
    when :spare then first_throw
    when :strike then frame_scores.sum
    when :double_strike
      # 最終フレーム直前の場合処理が変わる
      if frame_count > 9
        first_throw
      else
        first_throw + frame_scores.sum
      end
    else 0
    end
  end

  def game_data_splitted_by_frame
    strike = 'X'
    game_data.split(',').each_with_object([]) do |v, array|
      case v
      when strike then array.push(10, 0)
      else array.push(v.to_i)
      end
    end.each_slice(2).to_a
  end
end

# 結果は第一引数に渡される
game_data = ARGV[0]

# 入力忘れ用
if game_data.nil?
  puts '第一引数に結果を渡してください。'
  return
end

bowling_score_calculator = BowlingScoreCalculator.new(game_data)
bowling_score_calculator.calculate

puts bowling_score_calculator.total_score
