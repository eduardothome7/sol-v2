# ---- BUILDER ----

FROM ruby:3.2 AS builder

# Instala dependências do sistema

RUN apt-get update -qq && apt-get install -y 
build-essential 
libpq-dev 
nodejs 
curl 
gnupg

# Adiciona repositório oficial do Yarn e instala

RUN curl -sS [https://dl.yarnpkg.com/debian/pubkey.gpg](https://dl.yarnpkg.com/debian/pubkey.gpg) | gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg 
&& echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] [https://dl.yarnpkg.com/debian](https://dl.yarnpkg.com/debian) stable main" 
> /etc/apt/sources.list.d/yarn.list 
&& apt-get update -qq && apt-get install -y yarn

WORKDIR /app

# Copia Gemfile e instala gems

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia todo o app

COPY . .

# ---- FINAL IMAGE ----

FROM ruby:3.2-slim

WORKDIR /app

# Copia gems e app da stage builder

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Adiciona gems ao PATH

ENV PATH="/usr/local/bundle/bin:${PATH}"

# Expõe porta do Rails

EXPOSE 3000

# Comando padrão

CMD ["rails", "server", "-b", "0.0.0.0"]
