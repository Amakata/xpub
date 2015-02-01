#!/usr/bin/env ruby

require 'json'

class PandocFilter

 def initialize filters
  @filters = filters
 end

 def filter_str str
  doc = JSON.parse str
  doc.each {  |child| 
   filter_node doc, child
  }
  JSON.generate doc
 end

 def before_filter doc, node
  @filters.each { |f| 
   f.filter doc, node, "before"
  }
 end

 def after_filter doc, node
  @filters.each { |f| 
   f.filter doc, node, "after"
  }
 end

 def filter_node doc, node
  if  node.kind_of?(String)
  elsif node.kind_of?(Array)
   before_filter doc, node
   node.each { |child| 
    filter_node doc, child
   }
   after_filter doc, node
  elsif node.kind_of?(Hash)
   if node.has_key? "t"
    before_filter doc, node
    filter_node doc, node["c"]
    after_filter doc, node
   end
  else 
  end
 end
end



# ルビフィルタ
# グループルビ
# {電子出版|でんししゅっぱん}を手軽に
# <ruby>電子出版<rt>でんししゅっぱん</rt></ruby>を手軽に
# 熟語ルビ
# {電子出版|でん|し|しゅっ|ぱん}を手軽に
# <ruby>電<rt>でん</rt>子<rt>し</rt>出<rt>しゅっ</rt>版<rt>ぱん</rt>を手軽に</p>
class FuriganaFilter

 def pattern
  /{([^|]+)\|([^|}]+(\|[^|}]+)*)}/
 end

 def split pattern, str
  if str.match pattern
   if $` == ""
    [[$&,true]].concat split(pattern, $')
   else
    [[$`, false],[$&,true]].concat split(pattern, $')
   end
  else
   if str == ""
    []
   else
    [[str, false]]
   end
  end
 end


 def replace str
  str.match(pattern) { |md|
   phrase = md[1]
   ruby_chars = md[2].split('|')
   if phrase.length == ruby_chars.length
    # 熟語ルビ
    "<ruby>" + phrase.split("").zip(ruby_chars).map {|c,r|
     "#{c}<rt>#{r}</rt>"
    }.join("") + "</ruby>"
   else
    # グループルビ
    "<ruby>#{phrase}<rt>#{ruby_chars.join("")}</rt></ruby>"
   end
  }
 end

 def filter doc, node, mode
  if mode == "before" && node.kind_of?(Array)
   new_node = []
   node.each { |child|
    if child.kind_of?(Hash) && 
      child["t"] == "Str" && 
      child["c"].match(pattern)
     split(pattern, child["c"]).map { |str, flag|
      if flag
       new_node << { "t" => "RawInline","c" => ["html",replace(str)]}
      else
       new_node << { "t" => "Str", "c" => str }
      end
     }
    else
     new_node << child
    end
   }
   node.replace new_node
  end
 end
end

# 改ページフィルタ
# なにもうめこまない。chapter単位で分割する
class NewPageFilter

 def pattern
  /^===.*$/
 end

 def filter doc, node, mode
  if mode == "before" && node.kind_of?(Hash)
   if node["t"] == "Para" &&
     node["c"].count == 1 &&
     node["c"][0]["t"] == "Str" &&
     node["c"][0]["c"].match(pattern)
    node["c"][0]["t"] = "RawInline"

    l = node["c"][0]["c"].length
    node["c"][0]["c"] = ["html",""]
   end
  end
 end
end

# 縦横中フィルタ
class TateNakaYokoFilter

 def pattern
  /\^([^^]+)\^/
 end

 def split pattern, str
  if str.match pattern
   if $` == ""
    [[$&,true]].concat split(pattern, $')
   else
    [[$`, false],[$&,true]].concat split(pattern, $')
   end
  else
   if str == ""
    []
   else
    [[str, false]]
   end
  end
 end


 def replace str
  str.match(pattern) { |md|
   word = md[1]
   "<span class=\"tcy\">#{word}</span>"
  }
 end

 def filter doc, node, mode
  if mode == "before" && node.kind_of?(Array)
   new_node = []
   node.each { |child|
    if child.kind_of?(Hash) && 
      child["t"] == "Str" && 
      child["c"].match(pattern)
     split(pattern, child["c"]).map { |str, flag|
      if flag
       new_node << { "t" => "RawInline","c" => ["html",replace(str)]}
      else
       new_node << { "t" => "Str", "c" => str }
      end
     }
    else
     new_node << child
    end
   }
   node.replace new_node
  end
 end
end

filters = [
 FuriganaFilter.new,
 TateNakaYokoFilter.new,
 NewPageFilter.new
]

puts PandocFilter.new(filters).filter_str STDIN.read


