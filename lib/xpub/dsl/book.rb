module Xpub
  class CallBook
    attr_reader :name, :src_files, :resource_files, :creators, :contributors, :identifiers

    dsl_accessor :title, default: 'UNTITLED'
    dsl_accessor :subtitle
    dsl_accessor :short
    dsl_accessor :collection
    dsl_accessor :edition
    dsl_accessor :extended
    dsl_accessor :publisher
    dsl_accessor :rights
    dsl_accessor :publication
    dsl_accessor :modification
    dsl_accessor :lang, default: 'ja'
    dsl_accessor :description

    def initialize(name)
      @name = name
      @creators = []
      @contributors = []
      @identifiers = []
      @src_files = []
      @resource_files = []
      @builders = []
      @checkers = []
    end

    def validate
    end

    def build(option)
      puts "build #{@name} book.".color :green
      @builders.each do |b|
        b.build option if !option[:builder] || option[:builder] == b.name
      end
    end

    def check(option)
      puts "check #{@name} book.".color :green
      @checkers.each do |c|
        c.check option if !option[:checker] || option[:checker] == c.name
      end
    end

    class CallAuthor
      attr_reader :name
      dsl_accessor :role

      def initialize(name)
        @name = name
      end

      def validate
      end
    end

    def creator(name, &block)
      call = CallAuthor.new name
      call.instance_eval(&block) if block
      call.validate
      @creators << call
    end

    def contributor(name, &block)
      call = CallAuthor.new name
      call.instance_eval(&block) if block
      call.validate
      @contributors << call
    end

    class CallIdentifier
      attr_reader :identifier
      dsl_accessor :scheme
      dsl_accessor :type_value

      def initialize(identifier)
        @identifier = identifier
      end

      def validate
      end
    end

    def identifier(identifier, &block)
      call = CallIdentifier.new identifier
      call.instance_eval(&block) if block
      call.validate
      @identifiers << call
    end
  end

  def self.book(name, &block)
    call = CallBook.new name
    call.instance_eval(&block) if block
    call.validate
    BookManager.instance.add call
  end

  class BookManager
    include Singleton
    def initialize
      @books = []
    end

    def add(b)
      @books << b
    end

    def build(option)
      @books.each do |book|
        book.build option if !option[:book] || option[:book] == book.name
      end
    end

    def check(option)
      @books.each do |book|
        book.check option if !option[:book] || option[:book] == book.name
      end
    end
  end
end
