# Onboarding API Calendário

API para gerenciamento de eventos

## Instalação

Primeiramente clone o projeto:

```bash
  git clone https://git.campuscode.com.br/onboarding2021agosto/onboarding_joaopedro.git
  cd onboarding_joaopedro
```

### Usando Docker Compose

```bash
docker-compose build
docker compose up
```

Em seguida, clique no link a seguir:
http://localhost:5000

### Usando Docker

Entre na pasta do projeto, builde e rode o docker da aplicação:

```bash
docker build --tag onboarding_jp .
docker run -p 80:5000 onboarding_jp
```

Em seguida, clique no link a seguir:
http://localhost

Observação: as chamadas de API vão ser no 'http://localhost' e não no 'http://localhost:5000'

### Sem Docker

É necessário estar com o Ruby versão 3.0.1

```bash
bundle install
bundle exec rackup --host 0.0.0.0 -p 5000
```

Em seguida, clique no link a seguir:
http://localhost:5000

## Ferramentas Usadas

## Como usar a API

#### Acessar todos os eventos

```
GET '/v1/events'
```

#### Acessar um evento

```
GET '/v1/events/:id'
```

#### Criar um evento

```
POST '/v1/events/'
```

#### Acessar documentos de um evento

```
GET '/v1/events/:event_id/documents'
```

#### Acessar documento de um evento

```
GET '/v1/events/:event_id/documents/:id'
```

#### Criar documento para um evento

```
POST '/v1/events/:event_id/documents'
```

## Authors

- [@joao.matias](https://git.campuscode.com.br/joao.matias)
