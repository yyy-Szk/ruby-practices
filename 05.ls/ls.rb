#! /usr/bin/env ruby
# frozen_string_literal: true

class ListSegments
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def self.call(path = '.')
    new(path).call
  end

  def call
    Dir.foreach(path) do |file_name|
      # optionは未実装なので、隠しファイルは表示しない

      next if file_name.start_with?('.')

      print file_name, (' ' * 6)
    end
  end
end

path = ARGV[0] || '.'
ListSegments.call(path)
