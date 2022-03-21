#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'extensions/file_util_wrapper'
require_relative 'file_detail'

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
      file_detail = FileDetail.new(File.join(path, filename))
      total_block_size += file_detail.block_size

      file_detail
    end

    puts "total #{total_block_size}"

    max_column_size_by_column_name = calculate_max_column_size_by_column_name(rows)
    rows.each do |row|
      puts format_row(row, max_column_size_by_column_name)
    end
  end

  def format_row(row, max_column_size_by_column_name)
    cols = []
    cols << row.file_type_and_permissions.to_s.ljust(11)
    cols << row.hard_link_count.to_s.rjust(max_column_size_by_column_name[:hard_link_count])
    cols << row.owner_name.to_s.ljust(max_column_size_by_column_name[:owner_name] + 1)
    cols << row.owner_group_name.to_s.ljust(max_column_size_by_column_name[:owner_group_name] + 1)
    cols << row.file_size.to_s.rjust(max_column_size_by_column_name[:file_size])
    cols << row.datetime.to_s
    cols << row.filename.to_s

    cols.join("\s").strip
  end

  def calculate_max_column_size_by_column_name(rows)
    column_names = %i[
      file_type_and_permissions
      hard_link_count
      owner_name
      owner_group_name
      file_size
      datetime
      filename
    ]

    max_column_size_by_column_name = {}
    column_names.each do |column_name|
      max_column_size = rows.map { |row| row.send(column_name).to_s }.max_by(&:size).size

      max_column_size_by_column_name[column_name] = max_column_size
    end

    max_column_size_by_column_name
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
