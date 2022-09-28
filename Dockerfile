FROM ubuntu:22.04

# Install some dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:rael-gc/rvm && \
    apt-get update && \
    apt-get install -y ruby ruby-dev build-essential

# Install bundler
ENV BUNDLER_VERSION 2.3
RUN gem install bundler -v $BUNDLER_VERSION

COPY . /blog
WORKDIR /blog
RUN bundle install

CMD bundle exec jekyll build && bundle exec jekyll s -DIl --host 0.0.0.0
