# frozen_string_literal: true

require_relative '../05.ls/ls'

RSpec.describe LS do
  describe 'self.call' do
    # ruby-practicesディレクトリから実行されることを想定
    context "引数なしの場合" do
      example 'コマンドを実行したディレクトリ内のファイル一覧 が表示される' do
        expect { LS.call }.to(output(<<~FILE_LIST).to_stdout)
          01.fizzbuzz   05.ls               09.wc_object
          02.calendar   06.wc               README.md
          03.rake       07.bowling_object   spec
          04.bowling    08.ls_object
        FILE_LIST
      end
    end

    context "引数ありの場合" do
      example '引数として指定したディレクトリ内のファイル一覧 が表示される' do
        expect { LS.call('05.ls') }.to(output(<<~FILE_LIST).to_stdout)
          ls.rb
        FILE_LIST
      end
    end
  end
end
