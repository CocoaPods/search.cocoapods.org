FROM ruby:2.3.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN apt-get update \
    && apt-get install -y postgresql libpq-dev postgresql-server-dev-9.4

RUN bundle install

COPY . /usr/src/app

ENV PORT 3000
EXPOSE 3000

CMD ["bundle", "exec", "foreman", "start"]
