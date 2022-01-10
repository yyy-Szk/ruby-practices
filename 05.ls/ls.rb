#! /usr/bin/env ruby
# frozen_string_literal: true

class LS
  MAX_COLUMN_SIZE = 3
  BLANK_AFTER_FILENAME = "\s" * 3

  def self.output(path = '.')
    new(path).output
  end

  def initialize(path)
    @path = path
  end

  def output
    target_files = Dir.glob('*', base: @path).sort
    max_row_size = calculate_max_row_size(target_files)
    columns = build_columns(target_files, max_row_size)

    max_row_size.times do |i|
      row_content =
        columns
        .map { |column| column.file_name(i) }
        .join(BLANK_AFTER_FILENAME)
        .strip
      puts row_content
    end
  end

  private

  Column = Struct.new(:file_names) do
    def file_name(index)
      file_names[index].to_s.ljust(column_length)
    end

    def column_length
      @column_length ||= file_names.max_by(&:size).size
    end
  end

  def build_columns(target_files, max_row_size)
    nested_filenames = []
    target_files.each do |filename|
      if nested_filenames.last.nil? || nested_filenames.last.size >= max_row_size
        nested_filenames << [filename]
      else
        nested_filenames.last << filename
      end
    end

    nested_filenames.map { |filenames| Column.new(filenames) }
  end

  def calculate_max_row_size(target_files)
    (target_files.size.to_f / MAX_COLUMN_SIZE).ceil
  end
end

path = ARGV[0] || '.'
LS.output(path)
