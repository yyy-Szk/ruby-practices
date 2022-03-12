require_relative './file_util'

class FileUtilWrapper < FileUtil
  def self.xattr_exist?(path)
    return unless File.exist?(path)

    super == C_TRUE ? true : false
  end
end

