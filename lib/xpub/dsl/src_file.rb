# Xpub module
module Xpub
  class CallBook
    class CallSrcFile
      attr_reader :file

      def initialize(file)
        @file = file
      end

      def full_path
        "#{Dir.getwd}/src/#{@file}"
      end

      def validate
        raise "File does not exist.#{full_path}" unless File.exist? full_path
      end

      def debug
        p full_path
      end
    end

    class CallMdFile < CallSrcFile
      def initialize(file)
        file += '.md' unless file =~ '.md$'
        super file
      end
    end

    class CallImgFile < CallSrcFile
      def validate
        super
        raise "Image File Ext is not Image Ext. #{@file}" unless @file =~ '.(jpeg|jpg|png|bmp|pdf)$'
      end
    end

    class CallImgFiles
      attr_reader :dir

      def initialize(dir)
        @dir = dir
      end

      def full_path
        "#{Dir.getwd}/src/#{@dir}"
      end

      def validate
        raise "Image Dir does not exist.#{full_path}" unless Dir.exist? full_path
      end

      def img_files
        validate
        Dir.glob("#{full_path}/**/*.{jpeg,jpg,png,bmp,pdf}").sort.map do |path|
          img = CallImgFile.new path.sub(full_path + '/', '')
          img.validate
          img
        end
      end
    end

    class CallMdFiles
      attr_reader :dir

      def initialize(dir)
        @dir = dir
      end

      def full_path
        "#{Dir.getwd}/src/#{@dir}"
      end

      def validate
        raise "Markdown Dir does not exist.#{full_path}" unless Dir.exist? full_path
      end

      def md_files
        validate
        Dir.glob("#{full_path}/**/*.md").sort.map do |path|
          mf = CallMdFile.new path.sub("#{Dir.getwd}/src/", '')
          mf.validate
          mf
        end
      end

      def debug
        p full_path
      end
    end

    def md_file(file, &block)
      call = CallMdFile.new file
      call.instance_eval(&block) if block
      call.validate
      @src_files << call
    end

    def md_files(dir, &block)
      call = CallMdFiles.new dir
      call.instance_eval(&block) if block
      call.validate
      @src_files.concat call.md_files
    end

    def img_file(file, &block)
      call = CallImgFile.new file
      call.instance_eval(&block) if block
      call.validate
      @resource_files << call
    end

    def img_files(dir, &block)
      call = CallImgFiles.new dir
      call.instance_eval(&block) if block
      call.validate
      @resource_files.concat call.img_files
    end
  end
end
