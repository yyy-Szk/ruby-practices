#! /usr/bin/env ruby
# frozen_string_literal: true

class LS
  attr_reader :target_files

  def initialize(path)
    # オプションは未実装なので、隠しファイルは削除する
    @target_files = remove_secret_file(Dir.foreach(path).sort.to_a)
  end

  def self.call(path = '.')
    new(path).call
  end

  def call
    max_row_size.times do |i|
      row_content = columns.map { |column| column.row(i) }.join(blank_after_filename).strip
      puts row_content
    end
  end

  private

  def blank_after_filename
    "\s\s\s"
  end

  def remove_secret_file(exist_files)
    exist_files.reject { |filename| filename.start_with?('.') }
  end

  Column = Struct.new(:rows) do
    def row(index)
      rows[index].to_s.ljust(row_size)
    end

    def row_size
      rows.max_by(&:size).size
    end
  end

  def columns
    @columns ||= lambda {
      files_split_by_max_column_size = target_files.each_with_object([]) do |filename, array|
        if array.last.nil? || array.last.size >= max_row_size
          array << [filename]
        else
          array.last << filename
        end
      end
      files_split_by_max_column_size.map { |rows| Column.new(rows) }
    }.call
  end

  def max_column_size
    3
  end

  def max_row_size
    max_size = target_files.size / max_column_size
    max_size += 1 unless (target_files.size % max_column_size).zero?

    max_size
  end
end

path = ARGV[0] || '.'
LS.call(path)
