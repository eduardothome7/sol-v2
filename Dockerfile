# ---- BUILD ARGUMENTS ----

ARG RAILS_MASTER_KEY

FROM ruby:3.2

WORKDIR /app

# Dependências do sistema

RUN apt-get update -qq && apt-get install -y 
build-essential 
libpq-dev 
nodejs 
yarn

# Copia Gemfile para instalar gems primeiro

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copia todo o código

COPY . .

# Variáveis de ambiente

ENV RAILS_ENV=development

# Se quiser passar a master key no dev, pode setar aqui

ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Precompile só em produção

RUN if [ "$RAILS_ENV" = "production" ]; then 
bundle exec rails assets:precompile; 
fi

EXPOSE 3000

# Comando padrão: usa Puma se estiver em produção, Rails server em dev

CMD if [ "$RAILS_ENV" = "production" ]; then 
bundle exec puma -C config/puma.rb; 
else 
bin/rails server -b 0.0.0.0; 
fi
