#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'extensions/file_util_wrapper'
require_relative 'list_option_columns'

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
        output_file_detail_list(path, target_files)
      else
        output_file_list(target_files)
      end
      puts if is_multiple_paths && index != @paths.size
    end
  end

  private

  def output_file_list(target_files)
    max_row_size = (target_files.size.to_f / MAX_COLUMN_SIZE).ceil

    rows =
      target_files
      .each_slice(max_row_size)
      .map do |sliced_files|
        width_to_align = sliced_files.max_by(&:size).size
        sliced_files_padding_by_nil = sliced_files.values_at(0...max_row_size)

        sliced_files_padding_by_nil.map { |file| file.to_s.ljust(width_to_align) }
      end
      .transpose

    rows.each do |row|
      puts row.join(BLANK_AFTER_FILENAME).strip
    end
  end

  def output_file_detail_list(path, target_files)
    total_block_size = 0

    rows = target_files.map do |filename|
      list_option_columns = ListOptionColumns.new(File.join(path, filename))
      total_block_size += list_option_columns.block_size

      list_option_columns.sorted_column_list
    end

    puts "total #{total_block_size}"

    rows.each do |row|
      aligned_columns = row.map do |column_name, column_value|
        align_list_option_column(column_name, column_value, rows)
      end
      puts aligned_columns.join("\s").strip
    end
  end

  def align_list_option_column(column_name, column_value, rows)
    max_column_size = rows.map { |row| row[column_name].to_s }.max_by(&:size).size
    aligment_direction =
      case column_name
      when :file_type_and_permissions, :owner_name, :owner_group_name, :filename then 'left'
      else 'right'
      end
    width_to_align =
      case column_name
      when :file_type_and_permissions then 11
      when :owner_name, :owner_group_name then max_column_size + 1
      when :month, :day then 2
      when :time then 5
      else max_column_size
      end

    if aligment_direction == 'right'
      column_value.to_s.rjust(width_to_align)
    else
      column_value.to_s.ljust(width_to_align)
    end
  end

  def fetch_target_files(path)
    glob_args = ['*']
    glob_args << File::FNM_DOTMATCH if @options[:all]
    target_files = Dir.glob(*glob_args, base: path).sort

    @options[:reverse] ? target_files.reverse : target_files
  end
end

options = {}
cmd_line_options = OptionParser.new
cmd_line_options.on('-a', '--all') { options[:all] = true }
cmd_line_options.on('-r', '--reverse') { options[:reverse] = true }
cmd_line_options.on('-l', '--list') { options[:list] = true }

paths = cmd_line_options.parse(ARGV)
paths = ['.'] if paths.empty?

LS.output(paths, options)
