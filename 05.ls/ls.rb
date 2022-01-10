#! /usr/bin/env ruby
# frozen_string_literal: true

class LS
  attr_reader :target_files, :max_row_size, :columns

  MAX_COLUMN_SIZE = 3
  BLANK_AFTER_FILENAME = "\s" * 3

  def self.output(path = '.')
    new(path).output
  end

  def initialize(path)
    @target_files = Dir.glob('*', base: path).sort
    @max_row_size = calculate_max_row_size
    @columns = build_columns
  end

  def output
    max_row_size.times do |i|
      row_content = columns
                    .map { |column| column.row(i) }
                    .join(BLANK_AFTER_FILENAME)
                    .strip
      puts row_content
    end
  end

  private

  Column = Struct.new(:rows) do
    def row(index)
      rows[index].to_s.ljust(row_size)
    end

    def row_size
      @row_size ||= rows.max_by(&:size).size
    end
  end

  def build_columns
    files_split_by_max_column_size = target_files.each_with_object([]) do |filename, array|
      if array.last.nil? || array.last.size >= max_row_size
        array << [filename]
      else
        array.last << filename
      end
    end

    files_split_by_max_column_size.map { |rows| Column.new(rows) }
  end

  def calculate_max_row_size
    (target_files.size.to_f / MAX_COLUMN_SIZE).ceil
  end
end

path = ARGV[0] || '.'
LS.output(path)
