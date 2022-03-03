#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

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

    "#{file_types[file_status.ftype.to_sym]}#{permissions}"
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
    file_status.atime.month.to_s
  end

  def day
    file_status.atime.day.to_s
  end

  def time
    timestamp = file_status.atime

    "#{timestamp.hour.to_s.rjust(2, '0')}:#{timestamp.min.to_s.rjust(2, '0')}"
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
      # 一番最後の「ファイル名」だけ左揃えにする
      align = index == rows.transpose.size ? 'left' : 'right'

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

  # デフォルトで 左揃えとする
  def build_column(contents, align = 'left')
    Column.new(contents, align)
  end

  def calculate_max_row_size(target_files, max_column_size = MAX_COLUMN_SIZE)
    (target_files.size.to_f / max_column_size).ceil
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
