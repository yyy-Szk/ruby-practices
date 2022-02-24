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
          ls.rb   readme
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
          ls.rb   readme
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

    context 'listオプションを渡した場合' do
      context 'シンボリックリンクなしのケース' do
        example 'コマンドを実行したディレクトリ内のファイル一覧 が、ステータスと一緒に表示される' do
          expect { LS.output(['.'], { list: true }) }.to(output(<<~FILE_LIST).to_stdout)
            total 8
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96   2   9  19:56  01.fizzbuzz
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96  10   3  22:32  02.calendar
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96   8  29  20:39  03.rake
            drwxr-xr-x  4  yoshimasa-suzuki  staff   128   2  23  17:29  04.bowling
            drwxr-xr-x  4  yoshimasa-suzuki  staff   128   2  23  17:29  05.ls
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96   8  29  20:39  06.wc
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96   8  29  20:39  07.bowling_object
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96   8  29  20:39  08.ls_object
            drwxr-xr-x  3  yoshimasa-suzuki  staff    96   8  29  20:39  09.wc_object
            -rw-r--r--  1  yoshimasa-suzuki  staff  2336   8  29  20:39  README.md
            drwxr-xr-x  6  yoshimasa-suzuki  staff   192   2  23  15:43  spec
          FILE_LIST
        end
      end

      context 'シンボリックリンクありのケース' do
        example 'コマンドを実行したディレクトリ内のファイル一覧 が、ステータスと一緒に表示される' do
          expect { LS.output(['05.ls'], { list: true }) }.to(output(<<~FILE_LIST).to_stdout)
            total 16
            -rwxr-xr-x  1  yoshimasa-suzuki  staff  5337  2  23  20:50  ls.rb
            lrwxr-xr-x  1  yoshimasa-suzuki  staff    12  2  23  20:47  readme -> ../README.md
          FILE_LIST
        end
      end
    end

    context '全てのオプションを渡した場合' do
      example 'コマンドを実行したディレクトリ内のファイル一覧 が、隠しファイルを含め、ステータスと一緒に「降順」で表示される' do
        expect { LS.output(['.'], { all: true, reverse: true, list: true }) }.to(output(<<~FILE_LIST).to_stdout)
          total 48
          drwxr-xr-x   6  yoshimasa-suzuki  staff   192   2  23  15:43  spec
          -rw-r--r--   1  yoshimasa-suzuki  staff  2336   8  29  20:39  README.md
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96   8  29  20:39  09.wc_object
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96   8  29  20:39  08.ls_object
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96   8  29  20:39  07.bowling_object
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96   8  29  20:39  06.wc
          drwxr-xr-x   4  yoshimasa-suzuki  staff   128   2  23  17:29  05.ls
          drwxr-xr-x   4  yoshimasa-suzuki  staff   128   2  23  17:29  04.bowling
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96   8  29  20:39  03.rake
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96  10   3  22:32  02.calendar
          drwxr-xr-x   3  yoshimasa-suzuki  staff    96   2   9  19:56  01.fizzbuzz
          -rw-r--r--   1  yoshimasa-suzuki  staff   254   1  19  19:21  .rubocop.yml
          -rw-r--r--   1  yoshimasa-suzuki  staff    22  12  22  20:13  .rspec
          -rw-r--r--   1  yoshimasa-suzuki  staff  2090   8  29  20:39  .gitignore
          drwxr-xr-x  15  yoshimasa-suzuki  staff   480   2  23  20:24  .git
          -rw-r--r--   1  yoshimasa-suzuki  staff  6148  12  13  19:56  .DS_Store
          drwxr-xr-x   6  yoshimasa-suzuki  staff   192   2  23  18:37  ..
          drwxr-xr-x  18  yoshimasa-suzuki  staff   576   2  23  20:20  .
        FILE_LIST
      end
    end
  end
end
