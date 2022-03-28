# frozen_string_literal: true

require 'etc'

class FileDetail
  attr_reader :file_path, :file_status

  def initialize(file_path)
    @file_path = file_path
    # シンボリックリンクはそのままにしたいので、File#lstatを使用
    @file_status = File.new(file_path).lstat
  end

  def block_size
    # rubyのドキュメントを見ていると、nilになることもあるようなので #to_i する
    file_status.blocks.to_i
  end

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

  def datetime
    timestamp = file_status.ctime

    if timestamp < calculate_half_year_ago(Time.now)
      timestamp.strftime("%_m\s%e\s\s%Y")
    else
      timestamp.strftime("%_m\s%e\s%H:%M")
    end
  end

  def file_size
    file_status.size
  end

  private

  def build_permission(binary_num)
    text  = binary_num[0] == '1' ? 'r' : '-'
    text += binary_num[1] == '1' ? 'w' : '-'
    text += binary_num[2] == '1' ? 'x' : '-'

    text
  end

  def calculate_half_year_ago(time)
    target_year = time.year
    target_month = time.mon - 6
    if target_month.negative?
      target_year -= 1
      target_month += 12
    end

    Time.new(target_year, target_month, time.day, time.hour, time.min, time.sec)
  end
end
