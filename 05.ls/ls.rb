#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class Array
  def present?
    !(nil? || empty?)
  end
end

class LS
  MAX_COLUMN_SIZE = 3
  BLANK_AFTER_FILENAME = "\s" * 3

  def self.output(path = '.', options = [])
    new(path, options).output
  end

  def initialize(path, options)
    @path = path
    @options = options.join
  end

  def output
    target_files = fetch_target_files
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

  def fetch_target_files
    glob_args = ['*']
    glob_args << File::FNM_DOTMATCH if all_file_display_option_applied?

    Dir.glob(*glob_args, base: @path).sort
  end

  def all_file_display_option_applied?
    @options.include?('a')
  end

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

options, paths = ARGV.partition { |value| value.start_with?('-') }

if options.present? && !ARGV.first.start_with?('-')
  puts "不正なオプションです: #{ARGV.first}"
  return
end

# パスが複数来ていた場合、不正な引数である
if paths.size > 1
  puts '正しい引数を入力してください'
  return
end

path = paths.first || '.'

LS.output(path, options)
