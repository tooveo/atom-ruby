FROM ruby:2.3.3
MAINTAINER g8y3e <valentine.pavchuk@ironsrc.com>
RUN mkdir /usr/src/app
ADD . /usr/src/app
WORKDIR /usr/src/app

ENV SDK_VERSION 1.5.2

RUN gem install bundler
RUN gem install coveralls
RUN gem install rspec

RUN gem build iron_source_atom.gemspec
RUN gem install iron_source_atom-$SDK_VERSION.gem