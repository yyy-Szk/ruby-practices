#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class Array
  def split(size)
    nested_array = []
    self.each do |value|
      if nested_array.last.nil? || nested_array.last.size >= size
        nested_array << [value]
      else
        nested_array.last << value
      end
    end

    nested_array
  end
end

class LS
  MAX_COLUMN_SIZE = 3
  BLANK_AFTER_FILENAME = "\s" * 3

  def self.output(paths = ['.'], options = {})
    new(paths, options).output
  end

  def initialize(paths, options)
    @paths = paths
    @options = options
  end

  def output
    is_multiple_paths = @paths.size > 1

    @paths.each.with_index(1) do |path, index|
      puts "#{path}:" if is_multiple_paths
      output_file_list(path)
      puts if is_multiple_paths && index != @paths.size
    end
  end

  private

  def output_file_list(path)
    target_files = fetch_target_files(path)
    max_row_size = calculate_max_row_size(target_files)
    columns =
      target_files
      .split(max_row_size)
      .map { |splitted_files| build_column(splitted_files) }

    max_row_size.times do |i|
      row_content =
        columns
        .map { |column| column.file_name(i) }
        .join(BLANK_AFTER_FILENAME)
        .strip
      puts row_content
    end
  end

  def fetch_target_files(path)
    glob_args = ['*']
    glob_args << File::FNM_DOTMATCH if @options[:all]
    target_files = Dir.glob(*glob_args, base: path).sort

    @options[:reverse] ? target_files.reverse : target_files
  end

  Column = Struct.new(:file_names) do
    def file_name(index)
      file_names[index].to_s.ljust(column_length)
    end

    def column_length
      @column_length ||= file_names.max_by(&:size).size
    end
  end

  def build_column(filenames)
    Column.new(filenames)
  end

  def calculate_max_row_size(target_files)
    (target_files.size.to_f / MAX_COLUMN_SIZE).ceil
  end
end

options = {}
cmd_line_options = OptionParser.new
cmd_line_options.on('-a', '--all') { options[:all] = true }
cmd_line_options.on('-r', '--reverse') { options[:reverse] = true }

paths = cmd_line_options.parse(ARGV)
paths = ['.'] if paths.empty?

LS.output(paths, options)
