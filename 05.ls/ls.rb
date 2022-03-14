#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'extensions/file_util_wrapper'

class Time
  def half_year_ago
    target_year = self.year
    target_month = mon - 6
    if target_month < 0
      target_year -= 1
      target_month += 12
    end

    Time.new(target_year, target_month, day, hour, min, sec)
  end
end

class Array
  def split(size)
    nested_array = []
    each do |value|
      if nested_array.last.nil? || nested_array.last.size >= size
        nested_array << [value]
      else
        nested_array.last << value
      end
    end

    nested_array
  end
end

class Column
  attr_reader :contents, :align

  ALIGNMENT_METHODS = { right: 'rjust', left: 'ljust' }.freeze

  def initialize(contents, align)
    # 配列に数値が含まれていた時のために追加
    @contents = contents.map(&:to_s)
    @align = align
  end

  def content(index)
    contents[index].to_s.send(ALIGNMENT_METHODS[align.to_sym], column_length)
  end

  def column_length
    @column_length ||= contents.max_by(&:size).size
  end
end

class ListOptionColumns
  attr_reader :file_path, :file_status

  def initialize(file_path)
    @file_path = file_path
    # シンボリックリンクはそのままにしたいので、File#lstatを使用
    @file_status = File.new(file_path).lstat
  end

  def sorted_column_list
    # -lオプションで表示する項目の配列
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

    # 半年以上の場合、yearを表示する
    if timestamp < Time.now.half_year_ago
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
      # 縦並びを実現するために、「最大カラムごとの2次元配列」にしてから #transpose している
      .each_slice(max_row_size)
      # #transposeするために、要素数が max_row_size に満たないものを nil で埋めている
      .map { |sliced_files| sliced_files.values_at(0...max_row_size) }
      .transpose

    align_columns(rows).each do |row|
      puts row.join(BLANK_AFTER_FILENAME).strip
    end
  end

  def align_columns(rows)
    return rows if rows.size == 1

    # 引数を破壊的に変更することを防ぐために #dup する
    duplicated_rows = rows.dup

    MAX_COLUMN_SIZE.times do |column_no|
      column_length = calculate_column_length(duplicated_rows, column_no)
      duplicated_rows.each do |duplicated_row|
        duplicated_row[column_no] = duplicated_row[column_no].to_s.ljust(column_length)
      end
    end

    duplicated_rows
  end

  def calculate_column_length(rows, column_no)
    rows
      .map { |row| row[column_no].to_s }
      .max_by(&:size)
      .size
  end

  def output_file_detail_list(path, target_files)
    total_block_size = 0
    # -lオプションを使った場合、最大カラム数は1となる
    max_row_size = calculate_max_row_size(target_files, 1)

    rows = target_files.map do |filename|
      list_option_columns = ListOptionColumns.new(File.join(path, filename))
      total_block_size += list_option_columns.block_size

      list_option_columns.sorted_column_list
    end

    # カラムごとに構造体にしたいので、#transpose して行と列を入れ替える
    columns = rows.transpose.map.with_index(1) do |files, index|
      # 最初と最後だけ左揃えにする
      align = index == 1 || index == rows.transpose.size ? 'left' : 'right'

      build_column(files, align)
    end

    # 出力
    puts "total #{total_block_size}"
    max_row_size.times do |i|
      row_content =
        columns
        .map { |column| column.content(i) }
        .join("\s\s")
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

  def build_column(contents, align = 'left')
    Column.new(contents, align)
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
