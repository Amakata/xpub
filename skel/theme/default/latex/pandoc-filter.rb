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
# \ruby{>電子出版}{でんししゅっぱん}を手軽に
# 熟語ルビ
# {電子出版|でん|し|しゅっ|ぱん}を手軽に
# \ruby{電}{でん}\ruby{子}{し}\ruby{出}{しゅっ}\ruby{版}{ぱん}を手軽に</p>
class FuriganaFilter

 def pattern
  /{(([^|]|\s)+)\|(([^|}]|\s)+(\|([^|}]|\s)+)*)}/
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
   ruby_chars = md[3].split('|')
   if phrase.length == ruby_chars.length
    # 熟語ルビ
    phrase.split("").zip(ruby_chars).map {|c,r|
     "\\ruby{#{c}}{#{r}}"
    }.join ""
   else
    # グループルビ
    "\\ruby{#{phrase}}{#{ruby_chars.join("")}}"
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
       new_node << { "t" => "RawInline","c" => ["tex",replace(str)]}
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
# === だと\\newpage
# ==== だと\\clearpage
# ===== かそれ以上だと \\cleardoublepage
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
    if l == 3
     node["c"][0]["c"] = ["tex","\\newpage"]
    elsif l == 4
     node["c"][0]["c"] = ["tex","\\clearpage"]
    else
     node["c"][0]["c"] = ["tex","\\cleardoublepage"]
    end
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
   "\\pbox<y>{#{word}}"
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
       new_node << { "t" => "RawInline","c" => ["tex",replace(str)]}
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


# 改行フィルタ
# Markdownで文章を改行したあとに、空行を挿入せずに文章を続けるときに、単なる改行になるようなフィルタ
# Pandocに同様のオプションがあるためこのフィルタは使わない
class NewLineFilter
 def filter doc, node, mode
  if mode == "before" && node.kind_of?(Hash)
   if node["t"] == "Para"
    node["c"].each { |child| 
     if child.kind_of?(Hash)
      if child["t"] == "Space"
       child["t"] = "RawInline"
       child["c"] = ["tex", "\\\\"]
      end
     end
    }
   end
  end
 end
end

class ColumnFilter
 def pattern
  /\s*<!--\s*%%(twocolumn|onecolumn)%%\s*-->\s*/
 end
 def filter doc, node, mode
  if mode == "before" && node.kind_of?(Hash)
   if node["t"] == "RawBlock" && node["c"][0] == "html" && node["c"][1].match(pattern)
    node["c"][0] = "tex"
    node["c"][1].match(pattern) { |md| 
     node["c"][1] = "\\" + md[1]
    }
   end
  end
 end
end

class TocFilter
 def pattern
  /\s*<!--\s*%%toc%%\s*-->\s*/
 end
 def filter doc, node, mode
  if mode == "before" && node.kind_of?(Hash)
   if node["t"] == "RawBlock" && node["c"][0] == "html" && node["c"][1].match(pattern)
    node["c"][0] = "tex"
    node["c"][1] = "\\tableofcontents"
   end
  end
 end
end


filters = [
 FuriganaFilter.new,
 TateNakaYokoFilter.new,
 NewPageFilter.new,
 ColumnFilter.new,
 TocFilter.new,
# NewLineFilter.new
]

puts PandocFilter.new(filters).filter_str STDIN.read


