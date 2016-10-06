# zip4win Docker files

FROM ruby:2.3.1-alpine
MAINTAINER <ak.hisashi@gmail.com>

RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    rm -rf /var/cache/apk/*

ENV BUILD_PACKAGES="curl-dev build-base openssh" \
    DEV_PACKAGES="libxml2 libxml2-dev libxslt libxslt-dev \
                  sqlite-dev git nodejs"

RUN \
  apk --update --upgrade add $BUILD_PACKAGES $DEV_PACKAGES && \
  rm /var/cache/apk/*

RUN \
  gem install -N nokogiri && \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  rm -rf /usr/lib/lib/ruby/gems/*/cache/* && \
  rm -rf ~/.gem

# git clone
RUN git clone https://github.com/kazuhisa/zip4win.git

# bundle install
RUN cd /zip4win && bundle install --without development test

# assets precompile
RUN cd /zip4win && bin/rake assets:precompile

# start server
EXPOSE 9292
CMD cd /zip4win && bundle exec puma -e production

