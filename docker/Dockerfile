FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y pandoc
RUN apt-get install -y texlive
RUN apt-get install -y texlive-lang-cjk xdvik-ja
RUN apt-get install -y build-essential
RUN apt-get install -y ruby-dev ruby-bundler
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install xpub

# Default command
CMD ["/bin/bash --login"]
