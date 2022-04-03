#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

class WC
  ANY_WHITE_SPACE_REGEX = /[\x09-\x0d\x20]+/.freeze

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

    @file_paths.each do |file_path|
      file_content = File.read(file_path)
      output_content_table = build_output_content_table(file_content)

      total_number_of_lines  += output_content_table[:number_of_lines]
      total_number_of_words  += output_content_table[:number_of_words]
      total_content_bytesize += output_content_table[:content_bytesize]

      puts "#{output_content_table[:content]}\s#{file_path}"
    end

    return unless @file_paths.count > 1

    puts "#{total_number_of_lines.to_s.rjust(8)}#{total_number_of_words.to_s.rjust(8)}#{total_content_bytesize.to_s.rjust(8)}\stotal"
  end

  def output_by_std_input
    output_content_table = build_output_content_table(@std_input)

    puts output_content_table[:content]
  end

  def build_output_content_table(input_content)
    number_of_lines = input_content.count("\n")
    number_of_words = input_content.split(ANY_WHITE_SPACE_REGEX).count
    content_bytesize = input_content.bytesize

    output_content = number_of_lines.to_s.rjust(8)
    unless @options[:lines]
      output_content += number_of_words.to_s.rjust(8)
      output_content += content_bytesize.to_s.rjust(8)
    end

    { content: output_content, number_of_lines: number_of_lines, number_of_words: number_of_words, content_bytesize: content_bytesize }
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
    str_input = $stdin.gets
    until str_input.nil?
      std_inputs << str_input
      str_input = $stdin.gets
    end
    std_input_text = std_inputs.join
  end

  WC.output(file_paths, std_input_text, options)
end
