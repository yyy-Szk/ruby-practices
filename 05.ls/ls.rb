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
      target_files = fetch_target_files(path)

      puts "#{path}:" if is_multiple_paths
      if @options[:list]
        output_file_list_with_detail(path, target_files)
      else
        output_file_list(target_files)
      end
      puts if is_multiple_paths && index != @paths.size
    end
  end

  private

  def output_file_list(target_files)
    max_row_size = calculate_max_row_size(target_files)
    columns =
      target_files
      .split(max_row_size)
      .map { |splitted_files| build_column(splitted_files) }

    max_row_size.times do |i|
      row_content =
        columns
        .map { |column| column.content(i) }
        .join(BLANK_AFTER_FILENAME)
        .strip
      puts row_content
    end
  end

  def output_file_list_with_detail(path, target_files)
  end

  def fetch_target_files(path)
    glob_args = ['*']
    glob_args << File::FNM_DOTMATCH if @options[:all]
    target_files = Dir.glob(*glob_args, base: path).sort

    @options[:reverse] ? target_files.reverse : target_files
  end

  Column = Struct.new(:contents, :align) do
    def content(index)
      alignment_method =
        case align
        when 'right' then 'rjust'
        when 'left' then 'ljust'
        end

        contents[index].to_s.send(alignment_method, column_length)
    end

    def column_length
      @column_length ||= contents.max_by(&:size).size
    end
  end

  # デフォルトで 左揃えとする
  def build_column(contents, align = 'left')
    Column.new(contents, align)
  end

  def calculate_max_row_size(target_files, max_column_size = MAX_COLUMN_SIZE)
    (target_files.size.to_f / max_column_size).ceil
  end
end

# requireされた時に実行されないようにする
if $0 == __FILE__
  options = {}
  cmd_line_options = OptionParser.new
  cmd_line_options.on('-a', '--all') { options[:all] = true }
  cmd_line_options.on('-r', '--reverse') { options[:reverse] = true }
  cmd_line_options.on('-l', '--list') { options[:list] = true }

  paths = cmd_line_options.parse(ARGV)
  paths = ['.'] if paths.empty?

  LS.output(paths, options)
end
