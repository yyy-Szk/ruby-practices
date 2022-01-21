# frozen_string_literal: true

require_relative '../05.ls/ls'

RSpec.describe LS do
  describe 'self.output' do
    # ruby-practicesディレクトリから実行されることを想定
    context '引数なしの場合' do
      example 'コマンドを実行したディレクトリ内のファイル一覧 が表示される' do
        expect { LS.output }.to(output(<<~FILE_LIST).to_stdout)
          01.fizzbuzz   05.ls               09.wc_object
          02.calendar   06.wc               README.md
          03.rake       07.bowling_object   spec
          04.bowling    08.ls_object
        FILE_LIST
      end
    end

    context '引数あり(pathsの要素が1つ)の場合' do
      example '引数として指定したディレクトリ内のファイル一覧 が表示される' do
        expect { LS.output(['05.ls']) }.to(output(<<~FILE_LIST).to_stdout)
          ls.rb
        FILE_LIST
      end
    end

    context '引数あり(pathsの要素が2つ)の場合' do
      example '引数として指定した path と、そのディレクトリ内のファイル一覧 が表示される' do
        expect { LS.output(['.', '05.ls']) }.to(output(<<~FILE_LIST).to_stdout)
          .:
          01.fizzbuzz   05.ls               09.wc_object
          02.calendar   06.wc               README.md
          03.rake       07.bowling_object   spec
          04.bowling    08.ls_object

          05.ls:
          ls.rb
        FILE_LIST
      end
    end

    context 'allオプションを渡した場合' do
      example 'コマンドを実行したディレクトリ内のファイル一覧 が、隠しファイルを含め表示される' do
        expect { LS.output(['.'], { all: true }) }.to(output(<<~FILE_LIST).to_stdout)
          .            .rubocop.yml   06.wc
          ..           01.fizzbuzz    07.bowling_object
          .DS_Store    02.calendar    08.ls_object
          .git         03.rake        09.wc_object
          .gitignore   04.bowling     README.md
          .rspec       05.ls          spec
        FILE_LIST
      end
    end

    context 'reverseオプションを渡した場合' do
      example 'コマンドを実行したディレクトリ内のファイル一覧 が、降順で表示される' do
        expect { LS.output(['.'], { reverse: true }) }.to(output(<<~FILE_LIST).to_stdout)
          spec           07.bowling_object   03.rake
          README.md      06.wc               02.calendar
          09.wc_object   05.ls               01.fizzbuzz
          08.ls_object   04.bowling
        FILE_LIST
      end
    end

    context '全てのオプションを渡した場合' do
      example 'コマンドを実行したディレクトリ内のファイル一覧 が、隠しファイルを含め、降順で表示される' do
        expect { LS.output(['.'], { all: true, reverse: true }) }.to(output(<<~FILE_LIST).to_stdout)
          spec                05.ls          .rspec
          README.md           04.bowling     .gitignore
          09.wc_object        03.rake        .git
          08.ls_object        02.calendar    .DS_Store
          07.bowling_object   01.fizzbuzz    ..
          06.wc               .rubocop.yml   .
        FILE_LIST
      end
    end
  end
end
