# Xpub module
module Xpub
  class CallBook
    class CallChecker
      def initialize(name, book)
        @name = name
        @book = book
      end

      def validate
      end

      def _check(_option, pattern)
        words = {}
        @book.src_files.each do |file|
          f = open file.full_path
          f.each_with_index do |line, index|
            line.match(pattern) do |md|
              if words[md[1]]
                words[md[1]] << { file: file.file, line: (index + 1) }
              else
                words[md[1]] = [{ file: file.file, line: (index + 1) }]
              end
            end
          end
          f.close
        end

        words.sort.each do |word, infos|
          next unless word
          puts word.color :red
          infos.each do |info|
            puts "  #{info[:file]}(#{info[:line]})"
          end
        end
      end
    end

    class CallNumberChecker < CallChecker
      def check(option)
        _check option, /([０-９一二三四五六七八九十百千万億兆京〇零]+)/
      end
    end

    class CallKanaChecker < CallChecker
      def check(option)
        _check option, /([\p{Katakana}ー－]+)/
      end
    end

    def number_checker(name, &block)
      call = CallNumberChecker.new name, self
      call.instance_eval(&block) if block
      call.validate
      @checkers << call
    end

    def kana_checker(name, &block)
      call = CallKanaChecker.new name, self
      call.instance_eval(&block) if block
      call.validate
      @checkers << call
    end
  end
end
