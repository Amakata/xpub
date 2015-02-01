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
