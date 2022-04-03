# frozen_string_literal: true

require_relative '../06.wc/wc'

RSpec.describe WC do
  describe 'self.output' do
    # ruby-practicesディレクトリから実行されることを想定
    context 'ファイルのパスが空でかつ、標準入力を渡した場合' do
      example '標準入力に対する改行数、単語数、バイト数が順に表示される' do
        file_paths = []
        std_input = "hello world!\nhello world!"

        expect { WC.output(file_paths, std_input) }.to(output(<<-WORD_COUNT).to_stdout)
       1       4      25
        WORD_COUNT
      end
    end

    context 'ファイルのパスを1つ渡した場合' do
      example 'ファイルに対する改行数、単語数、バイト数が順に表示される' do
        file_paths = ['spec/06.wc/sample.txt']
        std_input = ''

        expect { WC.output(file_paths, std_input) }.to(output(<<-WORD_COUNT).to_stdout)
       1      11      65 spec/06.wc/sample.txt
        WORD_COUNT
      end
    end

    context 'ファイルのパスを2つ渡した場合' do
      example 'ファイルごとに、改行数、単語数、バイト数が順に表示され、最後に合計が出力される' do
        file_paths = ['spec/06.wc/sample.txt', 'spec/06.wc/hoge.txt']
        std_input = ''

        expect { WC.output(file_paths, std_input) }.to(output(<<-WORD_COUNT).to_stdout)
       1      11      65 spec/06.wc/sample.txt
       0       2      18 spec/06.wc/hoge.txt
       1      13      83 total
        WORD_COUNT
      end
    end

    context 'linesオプションを渡した場合' do
      let(:options) { { lines: true } }

      context 'ファイルパスが空でかつ、標準入力を渡したとき' do
        example '標準入力に対する改行数が表示される' do
          file_paths = []
          std_input = "hello world!\nhello world!"

          expect { WC.output(file_paths, std_input, options) }.to(output(<<-WORD_COUNT).to_stdout)
       1
          WORD_COUNT
        end
      end

      context 'ファイルパスを渡したとき' do
        example 'ファイルに対する改行数およびファイル名が順に表示される' do
          file_paths = ['spec/06.wc/sample.txt']
          std_input = ''

          expect { WC.output(file_paths, std_input, options) }.to(output(<<-WORD_COUNT).to_stdout)
       1 spec/06.wc/sample.txt
          WORD_COUNT
        end
      end
    end
  end
end
