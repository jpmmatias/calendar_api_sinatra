FROM ruby:3.0.1

RUN apt-get update
RUN mkdir /onboarding_api
WORKDIR /onboarding_api

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN gem install bundler && bundle install

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]

COPY . /onboarding_api


