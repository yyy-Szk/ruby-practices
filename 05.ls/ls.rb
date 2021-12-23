#! /usr/bin/env ruby
# frozen_string_literal: true

class ListSegments
  attr_reader :file_list

  def initialize(path)
    @file_list = Dir.foreach(path).sort.to_a
  end

  def self.call(path = '.')
    new(path).call
  end

  def call
    # optionは未実装なので、とりあえず隠しファイルは表示しない
    puts file_list_without_secret_file
  end

  private

  def file_list_without_secret_file
    file_list.reject { |filename| filename.start_with?('.') }
  end

  def max_colums
    3
  end

  def max_rows
    max_size = file_list.size / 3
    max_size + 1 unless (file_list.size % 3).zero?
  end


  class Column < Struct.new(:rows)
    def longest_filename_length
    end
  end
end


path = ARGV[0] || '.'
ListSegments.call(path)
