# ---- BUILD STAGE ----
FROM ruby:3.2 AS builder

# Instala dependências do sistema
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    curl

# Instala yarn
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn

WORKDIR /app

# Copia Gemfile primeiro e instala gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia todo o código
COPY . .

# Precompile dos assets em produção
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production
RUN bundle exec rails assets:precompile

# ---- FINAL STAGE ----
FROM ruby:3.2

# Dependências de runtime
RUN apt-get update -qq && apt-get install -y libpq-dev nodejs yarn

WORKDIR /app

# Copia do builder
COPY --from=builder /app /app

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
