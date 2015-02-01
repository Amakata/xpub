require 'singleton'

module Xpub
 class CallBook
  attr_reader :name, :src_files, :resource_files, :creators, :contributors, :identifiers

  def initialize name
   @name = name
   @title = "UNTITLED"
   @subtitle = nil
   @short = nil
   @collection = nil
   @edition = nil
   @extended = nil
   @publisher = nil
   @rights = nil
   @publication = nil
   @modification = nil
   @lang = "ja"
   @creators = []
   @contributors = []
   @identifiers = []
   @description = nil

   @src_files = []
   @resource_files = []
   @builders = []
  end


  def validate
  end

  def _set_or_get values
   # 引数が 2 つ以上ならエラー
   raise ArgumentError, "wrong number of arguments (#{ values.length} for 0..1)" if values.length > 1
   values.empty?
  end

  def title *values
   if _set_or_get values
    @title
   else
    @title = values[0]
   end
  end

  def subtitle *values
   if _set_or_get values
    @subtitle
   else
    @subtitle = values[0]
   end
  end

  def short *values
   if _set_or_get values
    @short
   else
    @short = values[0]
   end
  end

  def collection *values
   if _set_or_get values
    @collection
   else
    @collection = values[0]
   end
  end

  def edition *values
   if _set_or_get values
    @edition
   else
    @edition = values[0]
   end
  end

  def extended *values
   if _set_or_get values
    @extended
   else
    @extended = values[0]
   end
  end

  def publisher *values
   if _set_or_get values
    @publisher
   else
    @publisher = values[0]
   end
  end

  def rights *values
   if _set_or_get values
    @rights
   else
    @rights = values[0]
   end
  end

  def publication *values
   if _set_or_get values
    @publication
   else
    @publication = values[0]
   end
  end

  def modification *values
   if _set_or_get values
    @modification
   else
    @modification = values[0]
   end
  end

  def lang *values
   if _set_or_get values
    @lang
   else
    @lang = values[0]
   end
  end

  def description *values
   if _set_or_get values
    @description
   else
    @description = values[0]
   end
  end

  def build option
   puts "build #{@name} book.".color :green
   @builders.each { |b| 
    if !option[:builder] || option[:builder] == b.name
     b.build option
    end
   }
  end

  class CallAuthor
   attr_reader :name

   def initialize name
    @name = name
    @role = nil
   end

   def validate
   end

   def _set_or_get values
    # 引数が 2 つ以上ならエラー
    raise ArgumentError, "wrong number of arguments (#{ values.length} for 0..1)" if values.length > 1
    values.empty?
   end

   def role *values
    if _set_or_get values
     @role
    else
     @role = values[0]
    end
   end
  end

  def creator name, &block
   call = CallAuthor.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @creators << call
  end

  def contributor name, &block
   call = CallAuthor.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @contributors << call
  end

  class CallIdentifier
   attr_reader :identifier

   def initialize identifier
    @identifier = identifier
    @scheme = nil
    @type_value = nil
   end

   def validate
   end

   def _set_or_get values
    # 引数が 2 つ以上ならエラー
    raise ArgumentError, "wrong number of arguments (#{ values.length} for 0..1)" if values.length > 1
    values.empty?
   end

   def scheme *values
    if _set_or_get values
     @scheme
    else
     @scheme = values[0]
    end
   end

   def type_value *values
    if _set_or_get values
     @type_value
    else
     @type_value = values[0]
    end
   end
  end

  def identifier identifier, &block
   call = CallIdentifier.new identifier
   if block
    call.instance_eval &block
   end
   call.validate
   @identifiers << call
  end
 end

 def self.book name, &block
  call = CallBook.new name
  if block
   call.instance_eval &block
  end
  call.validate
  BookManager.instance.add call
 end

 class BookManager
  include Singleton
  def initialize
   @books = []
  end

  def add c
   @books << c
  end

  def build option
   @books.each { |book|
    if !option[:book] || option[:book] == book.name
     book.build option
    end
   }
  end
 end
end
