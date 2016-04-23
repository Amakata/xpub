# 概要

Docker Composerを利用してxpubを利用する環境を構築します。

# 準備

事前にDockerとDocker Composer等をいれておく必要があります。
[Docker Toolbox](https://www.docker.com/products/docker-toolbox) などを使って入れてください。

1. ターミナルを立ち上げてdocker-composer.ymlのあるディレクトリに移動

このファイルのあるディレクトリです。

docker-composer.yml、Dockerfileの二つがあればよく、他のファイルはなくても使えます。
(xpub本体は、githubからではなく、gemに公開されている最新版からとってきます。)


2. xpubの環境のビルド

ビルドは１コマンドですみます。ただ、いろいろなファイルをダウンロードしてくるので、すごく時間がかります。
時間がかかるのは初回だけで、一度実施してしまえば、次回からは時間がかかりません。

```
# docker-compose build
```

3. xpubの環境に入ってみる

下記でDocker上に構築されたxpubの環境に入ることができます。
```
# docker-compose run xpub bash
```

4. /rootディレクトリに移動する

xpubの環境の中で下記のようにして、移動します。これは、dockerを起動したホスト環境のdocker-composer.ymlと共有フォルダになっていて、xpubのdockerの環境からも、ホストマシンからも見ることができます。
```
# cd /root
# ls
Dockerfile  Readme.md  docker-compose.yml
```

5. サンプルファイルを用意する

xpubの環境内で、xpubの初期化を行います。

```
# xpub init
init...
```

```
# ls
Dockerfile  Readme.md  Xpub  docker-compose.yml  output  src  theme  tmp
```

ひな形のディレクトリとファイルができあがっています。


6. ビルドする。

xpubの環境の中でビルドしてみます。
```
# xpub build
build...
build sample book.
pandoc -o /root/tmp/sample/sample.tex -t latex --chapters -f markdown_phpextra\+hard_line_breaks\+raw_tex -s --template\=/root/theme/default/latex/template.tex --filter\=/root/theme/default/latex/pandoc-filter.rb -V documentclass\=utbook -V classoption\=11pt -V classoption\=twocolumn -V classoption\=twoside -V classoption\=a5j -V book_name\=sample /root/src/sample.md
copy sample1.jpg to tmp/
cd /root/tmp/sample;extractbb sample1.jpg
uplatex -output-directory\=/root/tmp/sample/ /root/tmp/sample/sample.tex
uplatex -output-directory\=/root/tmp/sample/ /root/tmp/sample/sample.tex
cd /root/tmp/sample/;dvipdfmx -o /root/output/sample.pdf /root/tmp/sample/sample.dvi
cd /root/tmp/sample/;pandoc -o /root/output/sample.epub -t epub3 --epub-chapter-level\=1 --toc -f markdown_phpextra\+hard_line_breaks\+raw_html -s --template\=/root/theme/default/epub/template.html --filter\=/root/theme/default/epub/pandoc-filter.rb --epub-stylesheet\=/root/theme/default/epub/epub.css --epub-metadata\=/root/tmp/sample/sample.metadata.dat --epub-cover-image\=/root/src/sample1.jpg -V title\=\サ\ン\プ\ル -V book_name\=sample -M page-progression-direction\=rtl /root/src/sample.md
```

すると、outputディレクトリの中にsample.pdfとsample.epubができあがっています。

dockerを起動したホスト環境で、sample.pdfとsample.epubを見てみましょう。

このファイルはXpubという設定ファイルとsrcディレクトリの下のMarkdwonとjpg画像から生成されています。

Xpubやマークダウンをかえて、

```
# xpub build
```
することで、pdfやepubを最新の状態にすることができます。

7. 終了

xpubの環境の中で

```
# exit
```
することで、終了できます。お疲れ様でした。

また使いたい場合はdocker-compose.ymlのあるディレクトリで下記のコマンドを実行します。

```
# docker-compose run xpub bash
```
