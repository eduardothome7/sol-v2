# ---- BUILDER ----
FROM ruby:3.2 AS builder

# Instala dependências do sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    curl \
    gnupg \
    yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

# ---- FINAL ----
FROM ruby:3.2-slim

WORKDIR /app

# Copia gems da stage builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

ENV PATH="/usr/local/bundle/bin:${PATH}"

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
