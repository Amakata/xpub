module Xpub
 class CallBook
  class CallLatexBuilder
   class CallLatexOp

    def initialize name, book, builder
     @name = name
     @book = book
     @builder = builder
    end
    def validate
    end

    def template_path
     "#{Dir::getwd}/theme/#{@builder.theme}/#{@name}/#{@metadata}.erb"
    end

    def latex book, builder
     f = open template_path
     erb = ERB.new f.read, nil, "-"
     f.close
     erb.result(binding)
    end

   end

   class CallImgPageLatexOp < CallLatexOp
    dsl_accessor :topoffset, :default => "0in"
    dsl_accessor :leftoffset, :default => "0in"
    dsl_accessor :file

    def latex book, builder
     <<"EOS"
\\enlargethispage{200truemm}%
\\thispagestyle{empty}%
\\vspace*{-1truein}
\\vspace*{-\\hoffset}
\\vspace*{-\\oddsidemargin}
\\vspace*{#{leftoffset}}
\\noindent\\hspace*{-1in}\\hspace*{-\\voffset}\\hspace*{-\\topmargin}\\hspace*{-\\headheight}\\hspace*{-\\headsep}\\hspace*{#{topoffset}}
\\includegraphics[width=\\paperheight,height=\\paperwidth]{#{file}}
\\clearpage\n
EOS
    end
   end

   class CallEmptyPageLatexOp < CallLatexOp
    dsl_accessor :no_page_number, :default => false

    def latex book, builder
     (no_page_number ? "\\thispagestyle{empty}" : "")  + "　\\clearpage\n"
    end
   end

   class CallInnerTitlePageLatexOp < CallLatexOp
    def latex book, builder
     <<"EOS"
\\makeatletter
{
\\thispagestyle{empty}%
\\if@twocolumn\\@restonecoltrue\\onecolumn
\\else\\@restonecolfalse\\newpage\\fi
\\begin{minipage}<y>[c]{\\textheight}
\\begin{center}
\\vspace*{2.5cm}
{\\bf \\Huge #{book.title}}
\\end{center}
\\vspace*{0.5cm}
\\begin{center}
{\\bf \\Large #{book.subtitle}}
\\end{center}
\\vspace*{1.5cm}
\\begin{center}
{\\Large #{book.creators.map { |c| c.name }.join " "}}
\\end{center}
\\vspace*{1.5cm}
\\begin{flushleft}
#{book.description}
\\end{flushleft}
\\end{minipage}
\\if@restonecol\\twocolumn\\else\\newpage\\fi
}%
\\makeatother
EOS
    end
   end

   def hyoushi_image_page name, &block
    call = CallImgPageLatexOp.new name, @book, self
    if block
     call.instance_eval &block
    end
    call.validate
    @hyoushi << call
   end

   def hyoushi_empty_page name, &block
    call = CallEmptyPageLatexOp.new name, @book, self
    if block
     call.instance_eval &block
    end
    call.validate
    @hyoushi << call
   end

   def hyoushi_inner_title_page name, &block
    call = CallInnerTitlePageLatexOp.new name, @book, self
    if block
     call.instance_eval &block
    end
    call.validate
    @hyoushi << call
   end

   def urahyoushi_image_page name, &block
    call = CallImgPageLatexOp.new name, @book, self
    if block
     call.instance_eval &block
    end
    call.validate
    @urahyoushi << call
   end

   def urahyoushi_empty_page name, &block
    call = CallEmptyPageLatexOp.new name, @book, self
    if block
     call.instance_eval &block
    end
    call.validate
    @urahyoushi << call
   end

  end
 end
end
