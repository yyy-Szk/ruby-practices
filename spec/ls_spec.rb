# frozen_string_literal: true

require_relative '../05.ls'

RSpecRSpec.describe ListSegments do
  describe 'self.call' do
    # ruby-practicesディレクトリから実行されることを想定
    example '動作の検証' do
      # 引数なしの場合
      expect(described_class.call).to(eq(
        <<~FILE_LIST.chomp
          01.fizzbuzz   05.ls               09.wc_object
          02.calendar   06.wc               README.md
          03.rake       07.bowling_object   spec
          04.bowling    08.ls_object
        FILE_LIST
      ))

      # 引数ありの場合
      expect(described_class.call('05.ls')).to(eq(
        <<~FILE_LIST.chomp
          ls.rb
        FILE_LIST
      ))
    end
  end
end

