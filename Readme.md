# Onboarding API Calendário

API para gerenciamento de eventos

# Instalação

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

Caso precise subir um shell:

```bash
docker-compose run --rm api bash
```

E talvez tenha que rodar rake tasks

```bash
rake db:setup
rake db:schema:load
```

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

# Ferramentas Usadas

# Como usar a API

## Acessar todos os eventos

### Request

```
GET '/v1/events'
```

### Exemplode de resposta

    HTTP/1.1 200 OK
    Content-Type: application/json
    [
      {
        "name": "mudou",
        "local": "São Paulo",
        "owner": {
          "id": 1,
          "name": "User",
          "email": "email@gmail.com"
        },
        "description": "evento",
        "start_date": "2022-04-23T18:25:43.511Z",
        "end_date": "2022-04-23T18:25:43.511Z",
        "documents": [],
        "participants": [
          {
            "id": 1,
           "name": "User",
            "email": "email@gmail.com"
         }
       ]
     },
      {
       "name": "CCXP 2",
        "local": "São Paulo",
        "owner": {
         "id": 1,
          "name": "User",
         "email": "email@gmail.com"
       },
       "description": "evento",
        "start_date": "2022-04-23T18:25:43.511Z",
       "end_date": "2022-04-23T18:25:43.511Z",
       "documents": [],
        "participants": [
         {
            "id": 1,
            "name": "User",
           "email": "email@gmail.com"
         }
       ]
     }
    ]

## Acessar um evento

### Request

```
GET '/v1/events/:id'
```

### Exemplode de resposta:

    HTTP/1.1 200 OK
    Content-Type: application/json
    {
      "name": "CCXP",
      "local": "São Paulo",
      "owner": {
        "id": 1,
        "name": "User",
        "email": "email@gmail.com"
     },
      "description": "evento",
      "start_date": "2022-04-23T18:25:43.511Z",
      "end_date": "2022-04-23T18:25:43.511Z",
      "documents": [],
      "participants": [
        {
          "id": 1,
          "name": "User",
          "email": "email@gmail.com"
        }
      ]
    }

## Criar um evento

### Request

```
POST '/v1/events/'
Body JSON:
{
  "name": "CCXP 2",
  "local": "São Paulo",
  "description": "evento",
  "start_date":"2022-04-23T18:25:43.511Z",
  "end_date": "2022-04-23T18:25:43.511Z"
 }
```

### Exemplo de resposta:

    HTTP/1.1 201 Created
    Content-Type: application/json
    {
      "name": "CCXP 2",
      "local": "São Paulo",
      "owner": {
        "id": 1,
        "name": "User",
        "email": "email@gmail.com"
      },
      "description": "evento",
      "start_date": "2022-04-23T18:25:43.511Z",
      "end_date": "2022-04-23T18:25:43.511Z",
      "documents": [],
      "participants": [
        {
          "id": 1,
          "name": "User",
          "email": "email@gmail.com"
        }
      ]
    }

## Criar eventos com CSV

### Request:

Adicionar 'file' como param

```
POST '/v1/events/csv'
Body Upload
file: events.csv
```

### Exemplo de resposta

    HTTP/1.1 201 Created
    Content-Type: application/json
    [
      {
        "name": "CCXP",
        "local": "São Paulo",
        "owner": {
          "id": 1,
          "name": "User",
          "email": "email@gmail.com"
        },
        "description": "evento",
        "start_date": "2022-04-23T18:25:43.511Z",
        "end_date": "2022-04-23T18:25:43.511Z",
        "documents": [],
        "participants": [
          {
            "id": 1,
            "name": "User",
            "email": "email@gmail.com"
          }
        ]
      },
      {
        "name": "CCXP",
        "local": "São Paulo",
        "owner": {
          "id": 1,
          "name": "User",
          "email": "email@gmail.com"
        },
        "description": "evento",
        "start_date": "2022-04-23T18:25:43.511Z",
        "end_date": "2022-04-23T18:25:43.511Z",
        "documents": [],
        "participants": [
          {
            "id": 1,
            "name": "User",
            "email": "email@gmail.com"
          }
        ]
      }
    ]

## Acessar documentos de um evento

### Request

```
GET '/v1/events/:event_id/documents'
```

### Exemplo de resposta

    HTTP/1.1 200 Success
    Content-Type: application/json
    [
      {
        "id":1,
        "event_id":1,
        "file_path":"spec/fixtures/teste.xlsx",
        "created_at":"2021-09-21T20:03:46.907Z",
        "updated_at":"2021-09-21T20:03:46.907Z",
        "file_type":"application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "file_name":"documento_2"
      },
      {
        "id":2,
        "event_id":1,
        "file_path":"spec/fixtures/teste.xlsx",
        "created_at":"2021-09-21T20:03:46.908Z",
        "updated_at":"2021-09-21T20:03:46.908Z",
        "file_type":"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "file_name":"documento_1"
        },
      {
        "id":3,
        "event_id":1,
        "file_path":"spec/fixtures/test_image.jpeg",
        "created_at":"2021-09-21T20:03:46.909Z",
        "updated_at":"2021-09-21T20:03:46.909Z",
        "file_type":"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "file_name":"documento_3"
        }
      ]

## Acessar documento de um evento

```
GET '/v1/events/:event_id/documents/:id'
```

### Exemplo de resposta

    HTTP/1.1 200 Success
    Content-Type: application/json
    {
      "id":1,
      "event_id":1,
      "file_path":"spec/fixtures/teste.xlsx",
      "created_at":"2021-09-21T20:03:46.907Z",
      "updated_at":"2021-09-21T20:03:46.907Z",
      "file_type":"application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "file_name":"documento_2"
    }

## Criar documento para um evento

### Request

Inserir 'file' como parâmentro

```
POST '/v1/events/:event_id/documents'
Body Upload
file: file.txt
```

### Resposta

    HTTP/1.1 201 Created
    {
      "id":1,
      "event_id":1,
      "file_path":"spec/fixtures/file.tx",
      "created_at":"2021-09-21T20:03:46.907Z",
      "updated_at":"2021-09-21T20:03:46.907Z",
      "file_type":"text/plain",
      "file_name":"file"
    }

## Download de documento de um evento

### Request

```
GET '/v1/events/:event_id/documents/:id/download'
```

## Criação de usuário

```
POST '/v1/users/new_account'
```

## Login de usuário

```
POST '/v1/users/login'
```

## Usuário ve todos os seus convites

```
GET '/v1/invites'
```

## Usuário convida outro usuário para evento

```
POST '/v1/events/:event_id/invite'
```

Convite pode ser enviado por ID do usuário:

```
{"user_id" : "1"}
```

Convite pode ser enviado por lista de emails:

```
{"users_emails" : "[email@gmail.com,email2@gmail.com]"}
```

## Usuário aceita convite

```
PUT '/v1/invites/:id/accept'
```

### Usuário recusa convite

```
PUT '/v1/invites/:id/accept'
```

## Usuário bota status com 'talvez' no convite

```
PUT '/v1/invites/:id/perhaps'
```

# Authors

- [@joao.matias](https://git.campuscode.com.br/joao.matias)
