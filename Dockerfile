# zip4win Docker files

FROM centos:centos6
MAINTAINER <ak.hisashi@gmail.com>

# タイムゾーンの変更
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY clock.txt /etc/sysconfig/clock
RUN chmod 0644 /etc/sysconfig/clock

# Perform updates
RUN yum -y update; yum clean all
RUN yum -y install \
openssl-devel \
readline-devel \
sqlite-devel \
gcc \
gcc-c++ \
kernel-devel \
make \
wget \
ping \
sudo \
git \
tar \
ImageMagick-devel

# Rubyのインストール
RUN wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz && \
tar xvf ruby-2.3.1.tar.gz && \
cd ruby-2.3.1 && \
./configure && \
make && \
make install && \
gem install bundler

# git clone
RUN git clone https://github.com/kazuhisa/zip4win.git

# bundle install
RUN cd /zip4win && bundle install --without development test

# assets precompile
RUN cd /zip4win && bin/rake assets:precompile

# アプリケーションサーバー起動
EXPOSE 9292
CMD cd /zip4win && RAILS_ENV=production bundle exec puma

