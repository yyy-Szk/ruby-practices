#! /usr/bin/env ruby
# frozen_string_literal: true

class ListSegments
  def initialize
  end

  def self.call
    self.new().call
  end

  def call
    puts 'called'
  end
end

ListSegments.call

