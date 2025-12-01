# ---- BASE ----
FROM ruby:3.2 AS builder

# Instala dependências do sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    curl \
    gnupg

# Adiciona repositório Yarn
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

# ---- BUILD ARGUMENTS ----
ARG RAILS_MASTER_KEY
ARG SECRET_KEY_BASE

# Define variáveis de ambiente para o build
ENV RAILS_ENV=production \
    RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Precompila assets com as variáveis disponíveis
RUN bundle exec rails assets:precompile

# ---- FINAL STAGE ----
FROM ruby:3.2-slim

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]