FROM ruby:2.6.3-alpine3.9 AS daimyo-build

RUN apk update && apk add git make gcc libc-dev g++ openssl openssl-dev

ADD Gemfile      /daimyo/Gemfile
ADD Gemfile.lock /daimyo/Gemfile.lock

WORKDIR /daimyo
RUN gem install bundler -N
RUN bundle install --deployment --without development,test -j4

FROM ruby:2.6.3-alpine3.9 AS daimyo-base

RUN apk update && apk add git openssl
WORKDIR /daimyo

COPY --from=daimyo-build /daimyo/ .

RUN gem install bundler -N
RUN bundle install --deployment --without development,test

ADD lib /daimyo/lib
ADD exe /daimyo/exe

ENTRYPOINT ["bundle", "exec"]
CMD ["exe/daimyo-bot"]
