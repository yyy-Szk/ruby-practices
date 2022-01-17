#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

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

  def fetch_target_files(path)
    glob_args = ['*']
    glob_args << File::FNM_DOTMATCH if @options[:all]

    Dir.glob(*glob_args, base: path).sort
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

options = {}
cmd_line_options = OptionParser.new
cmd_line_options.on('-a', '--all') { options[:all] = true }

paths = cmd_line_options.parse(ARGV)
paths = ['.'] if paths.empty?

LS.output(paths, options)
