# Xpub

Markdownから、PDFやEPUBを生成するためのフレームワークのプロトタイプです。

Ruby DSLによって1ファイルで生成のためのルールを設定できるようにし、
PDFやEPUB3の生成を自動化します。

このプロトタイプの目的は

* 多様化する出力フォーマットを１ソースで生成できるようにする場合のシンプルで、柔軟な定義方法の検証

です。

## Installation

動作確認はMacでしています。それ以外の環境については把握していませんがおそらくLinuxでも利用できると思います。

```
$ gem install xpub
```

でインストールします。

このツールを使うには他にPandocとLatexが必要です。


### TeX Live

#### MacTex.pkgをダウンロードしてインストール

http://tug.org/mactex/

参考) http://tandoori.hatenablog.com/entry/20130802/1375451791

#### TeX Live Utility.appを起動して、アップデート

```
Yosemiteを使う場合は、まずTeX Live Utilityを更新すること、メニューの「TeX Liveユーティリティ > 更新があるか確認」で更新すること。
そうしないとうまくTeXをアップデートできない
```

または

```
$ sudo tlmgr update --self --all
```

でもよいかも。

インストールディレクトリは

* 基本インストール
/usr/local/texlive/2014
* TEXMFLOCAL
/usr/local/texlive/texmf-local
* TEXMFHOME
~/Library/texmf

になるらしい。

```
$ kpsewhich -var-value TEXMF
```
で検索の優先順位がわかるらしい。


### pandoc 1.13.2

https://github.com/jgm/pandoc/releases

からダウンロードしてインストールしたり、 brew等でインストールしてください。

```
$ brew install pandoc
```

## Usage

## 初期化

```
$ mkdir project
$ cd project
$ xpub init
```

上記コマンドを実行することで、Xpubファイル、サンプルデータ、デフォルトテーマや各種からディレクトリをスケルトンを元に作成します。

## ビルド

```
$ xpub build
```

カレントディレクトリのXpub設定ファイルを元にビルドします。

```
$ xpub book --book=sample
```

Xpub設定ファイルのbook sampleのみビルドします。

```
$ xpub book --builder=epub
```

Xpub設定ファイルのbuilder epubのみビルドします。

```
$ xpub book -v
```

コマンドラインの実行結果を結果にかかわらず詳細に出力します。

```
$ xpub book --pandoc-json-output 
```

pandocのjsonオブジェクトをtmpフォルダに生成します。デバック用です。


## クリア

```
$ xpub clean
```

カレントディレクトリのtmpディレクトリ、outputディレクトリをクリアします。


# Xpubファイルの形式

Xpubファイルは```xpub init```をすることでひな形が作成されます。

下記はひな形の例です。

```ruby
Xpub::book "sample" do
  # identifier "urn:uuid:c12fdf58-6f2b-4a77-bd58-186b3192b52a" do
    # scheme "UUID"
  # end
  title "サンプル"
  # subtitle "サブタイトル"
  # short "短縮タイトル"
  # collection "コレクションタイトル"
  # edition "エディションタイトル"
  # extended "エクステンドタイトル"

  # publisher "○○出版社"
  creator "電書 電子" do
  #  role "aut"
  end
  # contributor "コントリビュータの名前" do
  #  role "ill"
  # end
  description "テストのアブストラクトです。長い文のアブストラクトだとどういう表示になるのかをテストしています。"
  # rights "権利表記"
  # publication "2015/01/22 18:10:00"
  # modification Time.now.to_s

  md_file "sample"
  # md_files "."

  img_file "sample1.jpg"
  # img_file "hyoushi.png"
  # img_file "urahyoushi.png"

  latex_builder "latex" do
    documentclass "utbook"
    classoption "11pt"
    classoption "twocolumn" 
    classoption "twoside"
    classoption "a5j"
    # prepartname "第"
    # postpartname "部"
    # prechaptername "第"
    # postchaptername "章"
    # output "sample"
    # theme "default"
    # template "template.tex"
    # filter "pandoc-filter.rb"

    hyoushi_image_page "h01" do
	  file "sample1.jpg"
	  topoffset "-0.8mm"
	  leftoffset "2.1mm"
    end
    hyoushi_empty_page "h02" do
	  no_page_number
    end
    hyoushi_inner_title_page "title"
    urahyoushi_empty_page "h03" do
	  no_page_number
    end
    urahyoushi_image_page "h04" do#
	  file "sample1.jpg"
	  topoffset "-0.8mm"
	  leftoffset "-5mm"
    end
  end
  
  epub_builder "epub" do
    cover_image "sample1.jpg"
  end
end
```

# Markdownの形式

本ツールのMarkdownの形式は現在のところpandocの読み込み形式に従います。

EPUB出力では下記のオプションが与えられた物として動作します。 

```markdown_phpextra+hard_line_breaks+raw_html```

PDF出力では下記のオプションが与えられた物として動作します。 

```markdown_phpextra+hard_line_breaks+raw_tex```

## ルビ

ルビの形式は下記のようなものを受け付けるようになっています。

### グループルビ
```
{ルビテスト|るび}
```

### 熟語ルビ
```
{ルビテスト|る|び|て|す|と}
```

ルビの中には全角文字が使われる前提になっています。

## 縦横中

縦横中の形式は下記のようなものを受け付けるようになっています。

```
^54^
```

## 改ページ

PDFでは、下記の指定で改ページを行うことができます。EPUBでは現時点では改ページはされません。

### LaTeXのnewpage相当
```
===
```

### LaTeXのclearpage相当
```
====
```

### LaTeXのcleardoublepage相当
```
=====
```

## LaTeX専用目次出力

目次を出力します。
```
<!-- %%toc%% -->
```

## LaTex専用カラム数変更

これ以降を改ページして２カラム出力にします。
```
<!-- %%twocolumn%% -->
```

これ以降を改ページして１カラム出力にします。

```
<!-- %%onecolumn%% -->
```



# メモ

## MacでのTeXのフォントの設定メモ

### 游明朝体・游ゴシック体

```
$ sudo mkdir -p /usr/local/texlive/texmf-local/fonts/opentype/yu-osx
$ cd /usr/local/texlive/texmf-local/fonts/opentype/yu-osx
$ sudo ln -fs "/Library/Fonts/Yu Gothic Bold.otf" YuGo-Bold.otf
$ sudo ln -fs "/Library/Fonts/Yu Gothic Medium.otf" YuGo-Medium.otf
$ sudo ln -fs "/Library/Fonts/Yu Mincho Demibold.otf" YuMin-Demibold.otf
$ sudo ln -fs "/Library/Fonts/Yu Mincho Medium.otf" YuMin-Medium.otf
$ sudo mktexlsr
$ sudo updmap-sys --setoption kanjiEmbed yu-osx
```

### ヒラギノフォント

```
$ sudo mkdir -p /usr/local/texlive/texmf-local/fonts/opentype/hiragino/
$ cd /usr/local/texlive/texmf-local/fonts/opentype/hiragino/
$ sudo ln -fs "/Library/Fonts/ヒラギノ明朝 Pro W3.otf" ./HiraMinPro-W3.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ明朝 Pro W6.otf" ./HiraMinPro-W6.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ丸ゴ Pro W4.otf" ./HiraMaruPro-W4.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ角ゴ Pro W3.otf" ./HiraKakuPro-W3.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ角ゴ Pro W6.otf" ./HiraKakuPro-W6.otf
$ sudo ln -fs "/Library/Fonts/ヒラギノ角ゴ Std W8.otf" ./HiraKakuStd-W8.otf
$ sudo mktexlsr
$ sudo updmap-sys --setoption kanjiEmbed hiragino
```
