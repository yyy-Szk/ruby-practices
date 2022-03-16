#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'extensions/file_util_wrapper'

class ListOptionColumns
  attr_reader :file_path, :file_status

  def initialize(file_path)
    @file_path = file_path
    # シンボリックリンクはそのままにしたいので、File#lstatを使用
    @file_status = File.new(file_path).lstat
  end

  def sorted_column_list
    [
      file_type_and_permissions,
      hard_link_count,
      owner_name,
      owner_group_name,
      file_size,
      month,
      day,
      time,
      filename
    ]
  end

  def block_size
    # rubyのドキュメントを見ていると、nilになることもあるようなので #to_i する
    file_status.blocks.to_i
  end

  private

  def filename
    name  = File.basename(file_path)
    name += "\s->\s#{File.readlink(file_path)}" if file_status.symlink?

    name
  end

  def file_type_and_permissions
    file_types = { file: '-', directory: 'd', link: 'l' }

    permissions =
      file_status
      .mode
      .to_s(8)
      .rjust(6, '0')
      .slice(3, 5)
      .each_char
      .map { |char| build_permission(char.to_i.to_s(2)) }
      .join
    exist_xattr_icon = FileUtilWrapper.xattr_exist?(file_path) ? '@' : ''

    "#{file_types[file_status.ftype.to_sym]}#{permissions}#{exist_xattr_icon}"
  end

  def hard_link_count
    file_status.nlink
  end

  def owner_name
    Etc.getpwuid(file_status.uid).name
  end

  def owner_group_name
    Etc.getgrgid(file_status.gid).name
  end

  def month
    file_status.ctime.month.to_s
  end

  def day
    file_status.ctime.day.to_s
  end

  def time
    timestamp = file_status.ctime

    if timestamp < calculate_half_year_ago(Time.now)
      timestamp.year
    else
      "#{timestamp.hour.to_s.rjust(2, '0')}:#{timestamp.min.to_s.rjust(2, '0')}"
    end
  end

  def file_size
    file_status.size
  end

  def build_permission(binary_num)
    text  = binary_num[0] == '1' ? 'r' : '-'
    text += binary_num[1] == '1' ? 'w' : '-'
    text += binary_num[2] == '1' ? 'x' : '-'

    text
  end

  def calculate_half_year_ago(time)
    target_year = time.year
    target_month = time.mon - 6
    if target_month < 0
      target_year -= 1
      target_month += 12
    end

    Time.new(target_year, target_month, time.day, time.hour, time.min, time.sec)
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
        output_file_detail_list(path, target_files)
      else
        output_file_list(target_files)
      end
      puts if is_multiple_paths && index != @paths.size
    end
  end

  private

  def output_file_list(target_files)
    max_row_size = calculate_max_row_size(target_files)

    rows =
      target_files
      .each_slice(max_row_size)
      .map { |sliced_files| align_contents(sliced_files.values_at(0...max_row_size), 'left', sliced_files.max_by(&:size).size) }
      .transpose

    rows.each do |row|
      puts row.join(BLANK_AFTER_FILENAME).strip
    end
  end

  def align_contents(array, aligment_direction, width_to_align)
    if aligment_direction == 'right'
      array.map { |content| content.to_s.rjust(width_to_align) }
    else
      array.map { |content| content.to_s.ljust(width_to_align) }
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

    # カラムごとの横幅を揃えるために、一度 #transpose して行と列を入れ替え、揃えた後で再度 #transpose して元に戻している
    sorted_rows =
      rows
      .transpose
      .map.with_index(0) do |columns, column_no|
        aligment_direction =
          case column_no
          when 0, 2, 3, 8 then "left"
          else "right"
          end
        width_to_align =
          case column_no
          when 0 then 11
          when 2, 3 then columns.map(&:to_s).max_by(&:size).size + 1
          when 5, 6 then 2
          when 7 then 5
          else
            columns.map(&:to_s).max_by(&:size).size
          end

        align_contents(columns, aligment_direction, width_to_align)
      end
      .transpose

    sorted_rows.each do |row|
      puts row.join("\s").strip
    end
  end

  def fetch_target_files(path)
    glob_args = ['*']
    glob_args << File::FNM_DOTMATCH if @options[:all]
    target_files = Dir.glob(*glob_args, base: path).sort

    @options[:reverse] ? target_files.reverse : target_files
  end

  def calculate_max_row_size(target_files)
    (target_files.size.to_f / MAX_COLUMN_SIZE).ceil
  end
end

# requireされた時に実行されないようにする
if $PROGRAM_NAME == __FILE__
  options = {}
  cmd_line_options = OptionParser.new
  cmd_line_options.on('-a', '--all') { options[:all] = true }
  cmd_line_options.on('-r', '--reverse') { options[:reverse] = true }
  cmd_line_options.on('-l', '--list') { options[:list] = true }

  paths = cmd_line_options.parse(ARGV)
  paths = ['.'] if paths.empty?

  LS.output(paths, options)
end
