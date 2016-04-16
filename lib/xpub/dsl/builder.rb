module Xpub
  class CallBook
    class CallBuilder
      attr_reader :name
      dsl_accessor :theme, default: 'default'
      dsl_accessor :output

      def initialize(name, book)
        @name = name
        @book = book
      end

      def build
        raise 'This method is not implement.'
      end

      def validate
        raise 'src_file is empty.' if @book.src_files.count == 0
      end

      def src_path(file)
        "#{Dir.getwd}/src/#{file}"
      end

      def tmp_path(file)
        "#{Dir.getwd}/tmp/#{@book.name}/#{file}"
      end

      def output_path(file)
        "#{Dir.getwd}/output/#{file}"
      end

      def copy_to_tmp(files)
        files.each do |file|
          pn = Pathname.new tmp_path(file.file)
          FileUtils.mkdir_p(pn.dirname) unless FileTest.exist?(pn.dirname)

          unless FileTest.exist?(tmp_path(file.file)) && File.mtime(src_path(file.file)) <= File.mtime(tmp_path(file.file))
            puts "copy #{file.file} to tmp/".color :white
            FileUtils.copy_entry(src_path(file.file), tmp_path(file.file))
          end
        end
      end

      def cmd_exec(cmd, args, option)
        cmd_line = cmd + ' ' + args.map do |arg|
          Shellwords.shellescape(arg)
        end.join(' ')
        puts cmd_line.color :cyan
        stdout, stderr, status = Open3.capture3 cmd_line
        puts stdout.color :green if option[:v] || status != 0
        if status != 0
          puts stderr.color :red
          puts 'error!'.color :red
          exit
        end
      end
    end

    class CallEpubBuilder < CallBuilder
      dsl_accessor :template, default: 'template.html'
      dsl_accessor :filter, default: 'pandoc-filter.rb'
      dsl_accessor :stylesheet, default: 'epub.css'
      dsl_accessor :metadata, default: 'metadata.dat'
      dsl_accessor :page_progression_direction, default: 'rtl'
      dsl_accessor :cover_image
      dsl_accessor :pandoc_cmd, default: 'pandoc'

      def initialize(name, book)
        @vars = []
        @meta = []
        @vars << ['title', book.title] if book.title != ''
        super name, book
      end

      def meta_option
        result = []
        @meta.concat([['page-progression-direction', page_progression_direction]]).each do |m|
          result << '-M'
          result << "#{m[0]}=#{m[1]}"
        end
        result
      end

      def vars_option
        result = []
        @vars.concat([[:book_name, @book.name]]).each do |v|
          result << '-V'
          result << "#{v[0]}=#{v[1]}"
        end
        result
      end

      def template_option
        "--template=#{Dir.getwd}/theme/#{theme}/#{@name}/#{template}"
      end

      def filter_option
        "--filter=#{Dir.getwd}/theme/#{theme}/#{@name}/#{filter}"
      end

      def stylesheet_option
        "--epub-stylesheet=#{Dir.getwd}/theme/#{theme}/#{@name}/#{stylesheet}"
      end

      def metadata_option
        '--epub-metadata=' + metadata_path
      end

      def metadata_path
        tmp_path("#{@book.name}.#{metadata}")
      end

      def metadata_template_path
        "#{Dir.getwd}/theme/#{theme}/#{@name}/#{metadata}.erb"
      end

      def epub_path
        output_path(@book.name) + '.epub'
      end

      def json_path
        tmp_path(@book.name) + '.json'
      end

      def _build_resource(files, _option)
        copy_to_tmp files
      end

      def pandoc_option(option)
        option = [
          '--epub-chapter-level=1',
          '--toc',
          '-f',
          'markdown_phpextra+hard_line_breaks+raw_html',
          '-s',
          template_option,
          filter_option,
          stylesheet_option,
          metadata_option
        ]
        option << '--epub-cover-image=' + src_path(cover_image) if cover_image
        option
      end

      def build_epub_metadata(option)
        f = open metadata_template_path
        erb = ERB.new f.read, nil, '-'
        f.close
        f = open metadata_path, 'w'
        f.write erb.result(binding)
        f.close
      end

      def build(option)
        FileUtils.mkdir_p(tmp_path('')) unless FileTest.exist?(tmp_path(''))

        build_epub_metadata option

        pandoc_option = pandoc_option(option).concat(vars_option).concat(meta_option).concat(@book.src_files.map(&:full_path))

        cmd_exec "cd #{tmp_path ''};" + pandoc_cmd, ['-o', json_path, '-t', 'json'].concat(pandoc_option), option if option['pandoc-json-output']
        cmd_exec "cd #{tmp_path ''};" + pandoc_cmd, ['-o', epub_path, '-t', 'epub3'].concat(pandoc_option), option
      end
    end

    class CallLatexBuilder < CallBuilder
      dsl_accessor :template, default: 'template.tex'
      dsl_accessor :filter, default: 'pandoc-filter.rb'
      dsl_accessor :extractbb_cmd, default: 'extractbb'
      dsl_accessor :pandoc_cmd, default: 'pandoc'
      dsl_accessor :latex_cmd, default: 'uplatex'
      dsl_accessor :dvipdfm_cmd, default: 'dvipdfmx'

      def initialize(name, book)
        @vars = []
        @hyoushi = []
        @urahyoushi = []
        super name, book
      end

      def documentclass(param)
        @vars << [:documentclass, param]
      end

      def classoption(param)
        @vars << [:classoption, param]
      end

      def prepartname(param)
        @vars << [:prepartname, param]
      end

      def postpartname(param)
        @vars << [:postpartname, param]
      end

      def prechaptername(param)
        @vars << [:prechaptername, param]
      end

      def postchaptername(param)
        @vars << [:postchaptername, param]
      end

      def vars_option
        result = []
        @vars.concat([[:book_name, @book.name]]).each do |v|
          result << '-V'
          result << "#{v[0]}=#{v[1]}"
        end
        result
      end

      def template_option
        "--template=#{Dir.getwd}/theme/#{theme}/#{@name}/#{template}"
      end

      def filter_option
        "--filter=#{Dir.getwd}/theme/#{theme}/#{@name}/#{filter}"
      end

      def tex_path
        tmp_path(@book.name) + '.tex'
      end

      def json_path
        tmp_path(@book.name) + '.json'
      end

      def dvi_path
        tmp_path(@book.name) + '.dvi'
      end

      def pdf_path
        if output
          output_path(output) + '.pdf'
        else
          output_path(@book.name) + '.pdf'
        end
      end

      def _build_resource(files, option)
        copy_to_tmp files
        files.each do |file|
          xbb = File.dirname(tmp_path(file.file)) + '/' + File.basename(tmp_path(file.file), '.*') + '.xbb'
          unless FileTest.exist?(xbb) && File.mtime(tmp_path(file.file)) <= File.mtime(xbb)
            cmd_exec "cd #{Shellwords.shellescape(File.dirname(tmp_path(file.file)))};#{extractbb_cmd}", [File.basename(file.file)], option
          end
        end
      end

      def build_resource(option)
        _build_resource @book.resource_files, option
      end

      def pandoc_option(_option)
        [
          '--chapters',
          '-f',
          'markdown_phpextra+hard_line_breaks+raw_tex',
          '-s',
          template_option,
          filter_option
        ]
      end

      def build(option)
        FileUtils.mkdir_p(tmp_path('')) unless FileTest.exist?(tmp_path(''))

        build_pandoc option
        build_resource option
        build_hyoushi option
        build_latex option
        build_pdf option
      end

      def build_pandoc(option)
        pandoc_option = pandoc_option(option).concat(vars_option).concat(@book.src_files.map(&:full_path))
        cmd_exec pandoc_cmd, ['-o', json_path, '-t', 'json'].concat(pandoc_option), option if option['pandoc-json-output']
        cmd_exec pandoc_cmd, ['-o', tex_path, '-t', 'latex'].concat(pandoc_option), option
      end

      def build_latex(option)
        cmd_exec latex_cmd, ["-output-directory=#{tmp_path('')}", tex_path], option
        cmd_exec latex_cmd, ["-output-directory=#{tmp_path('')}", tex_path], option
      end

      def build_hyoushi(option)
        open(tmp_path(@book.name + '.before_body.tex'), 'w') do |io|
          io.puts @hyoushi.map { |h| h.latex @book, self } .join
        end
        open(tmp_path(@book.name + '.after_body.tex'), 'w') do |io|
          io.puts @urahyoushi.map { |h| h.latex @book, self }.join
        end
      end

      def build_pdf(option)
        unless FileTest.exist?(pdf_path) && (File.mtime(dvi_path) <= File.mtime(pdf_path))
          cmd_exec "cd #{Shellwords.shellescape(tmp_path(''))};#{dvipdfm_cmd}", ['-o', pdf_path, dvi_path], option
        end
      end
    end

    def epub_builder(name, &block)
      call = CallEpubBuilder.new name, self
      call.instance_eval(&block) if block
      call.validate
      @builders << call
    end

    def latex_builder(name, &block)
      call = CallLatexBuilder.new name, self
      call.instance_eval(&block) if block
      call.validate
      @builders << call
    end
  end
end
