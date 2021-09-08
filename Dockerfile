FROM ruby:3.0.1
LABEL org.opencontainers.image.authors="https://git.campuscode.com.br/joao.matias"

RUN apt-get update
WORKDIR /onboarding_jp

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN gem install bundler && bundle install

EXPOSE 5000

<<<<<<< HEAD
CMD [ "rake db:setup" ] && [ "rake db:seed" ] && ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]
=======
CMD  "rake db:setup rake db:schema:load bundle exec rackup --host 0.0.0.0 -p 5000"
>>>>>>> main

COPY . /onboarding_jp
