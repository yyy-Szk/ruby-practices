#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class WC
  ANY_WHITE_SPACE_REGEX = /[\x09-\x0d\x20]+/

  def self.output(file_paths, std_input, options = {})
    WC.new(file_paths, std_input, options).output
  end

  def initialize(file_paths, std_input, options)
    @file_paths = file_paths
    @std_input = std_input
    @options = options
  end

  def output
    if @file_paths.empty?
      output_by_std_input
    else
      output_by_file_paths
    end
  end

  private

  def output_by_file_paths
    total_number_of_lines = 0
    total_number_of_words = 0
    total_content_bytesize = 0

    output_content_list = @file_paths.map do |file_path|
      file_content = File.read(file_path)
      number_of_lines = file_content.count("\n")
      number_of_words = file_content.split(ANY_WHITE_SPACE_REGEX).count
      content_bytesize = file_content.bytesize

      total_number_of_lines += number_of_lines
      total_number_of_words += number_of_words
      total_content_bytesize += content_bytesize

      output_content = number_of_lines.to_s.rjust(8)
      unless @options[:lines]
        output_content += number_of_words.to_s.rjust(8)
        output_content += content_bytesize.to_s.rjust(8)
      end
      output_content += file_path.rjust(file_path.size + 1)

      output_content
    end

    puts output_content_list.join("\n")
    if @file_paths.count > 1
      puts "#{total_number_of_lines.to_s.rjust(8)}#{total_number_of_words.to_s.rjust(8)}#{total_content_bytesize.to_s.rjust(8)}\stotal" 
    end
  end

  def output_by_std_input
    number_of_lines = @std_input.count("\n").to_s.rjust(8)
    number_of_words = @std_input.split(ANY_WHITE_SPACE_REGEX).count.to_s.rjust(8)
    content_bytesize = @std_input.bytesize.to_s.rjust(8)

    output_content = number_of_lines
    unless @options[:lines]
      output_content += number_of_words
      output_content += content_bytesize
    end

    puts output_content
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  cmd_line_options = OptionParser.new
  cmd_line_options.on('-l') { options[:lines] = true }

  file_paths = cmd_line_options.parse(ARGV)

  std_input_text = ''
  if file_paths.empty?
    std_inputs = []
    while str = $stdin.gets
      std_inputs << str
    end
    std_input_text = std_inputs.join
  end

  WC.output(file_paths, std_input_text, options)
end
