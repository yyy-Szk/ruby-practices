# frozen_string_literal: true

require_relative '../04.bowling/bowling'

RSpec.describe BowlingScoreCalculator do
  describe 'total_scoreの計算' do
    example do
      calculator = BowlingScoreCalculator.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
      calculator.calculate
      expect(calculator.total_score).to(eq(139))

      calculator = BowlingScoreCalculator.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
      calculator.calculate
      expect(calculator.total_score).to(eq(164))

      calculator = BowlingScoreCalculator.new('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
      calculator.calculate
      expect(calculator.total_score).to(eq(107))

      calculator = BowlingScoreCalculator.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
      calculator.calculate
      expect(calculator.total_score).to(eq(134))

      calculator = BowlingScoreCalculator.new('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
      calculator.calculate
      expect(calculator.total_score).to(eq(144))

      calculator = BowlingScoreCalculator.new('X,X,X,X,X,X,X,X,X,X,X,X')
      calculator.calculate
      expect(calculator.total_score).to(eq(300))
    end
  end
end
