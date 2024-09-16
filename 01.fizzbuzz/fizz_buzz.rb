# frozen_string_literal: true

(1..20).each do |num|
  output =
    if (num % 15).zero?
      'FizzBuzz'
    elsif (num % 3).zero?
      'Fizz'
    elsif (num % 5).zero?
      'Buzz'
    else
      num
    end

  puts output
end
