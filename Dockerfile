FROM ruby:3.2 as builder

WORKDIR /app

# Dependências do sistema
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  gnupg \
  nodejs

# Instala o Yarn via repositório oficial
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Copia Gemfile e instala gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia todo o código
COPY . .

# Precompile dos assets
ARG RAILS_MASTER_KEY
RUN RAILS_ENV=production RAILS_MASTER_KEY=$RAILS_MASTER_KEY bundle exec rails assets:precompile
