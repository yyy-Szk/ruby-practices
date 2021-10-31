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
    is_spare = false
    is_strike = false
    is_double_strike = false

    game_data_splitted_by_frame.each.with_index(1) do |data, frame_count|
      # 通常は1フレームにつき2投
      first_throw, second_throw = data
      frame_score = data.sum
      bonus_score = calculate_bonus_score(first_throw, second_throw, is_strike, is_double_strike, is_spare)
      is_spare, is_strike, is_double_strike = check_bonus_flags(first_throw, second_throw, is_strike, frame_count)

      @total_score += (frame_score + bonus_score)
    end
  end

  private

  def check_bonus_flags(first_throw, second_throw, is_strike, frame_count)
    # 最終フレーム直前の場合処理が変わる
    if frame_count > 9
      is_double_strike = first_throw == 10 && is_strike ? true : false
      is_spare = false
      is_strike = false

      return [is_spare, is_strike, is_double_strike]
    end

    if first_throw == 10
      is_double_strike = is_strike ? true : false
      is_strike = true
      is_spare = false
    elsif (first_throw + second_throw) == 10
      is_spare = true
      is_double_strike = false
      is_strike = false
    else
      is_spare = false
      is_double_strike = false
      is_strike = false
    end

    [is_spare, is_strike, is_double_strike]
  end

  def calculate_bonus_score(first_throw, second_throw, is_strike, is_double_strike, is_spare)
    score = 0
    score += (first_throw + second_throw) if is_strike
    score += first_throw if is_spare
    score += first_throw if is_double_strike

    score
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
