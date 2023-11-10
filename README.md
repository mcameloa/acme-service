# Acme Corp API Service

## Overview

Acme Corp's API service provides registered users access to comprehensive information about the company and its diverse product range. Our API has gained popularity for its extensive data offerings. However, we've recently implemented a 10,000 API requests per-user monthly limit to ensure equitable service distribution.

## Requirements

- Ruby 3.2.2
- Rails 7.1.1
- Postgrest
- Redis

## Installation & Setup
Clone the repository and install dependencies
```bash
git clone https://github.com/mcameloa/acme-project.git
cd acme-project
bundle install
```

Start Postgres and Redis with docker-compose
```bash
docker-compose up -d db redis
```
**Note:** You can omit this step if you have your own implementation.

Edit the `config/application.yml` with the credential of the database and redis.

Create database and run migrations
```bash
rails db:create db:migrate
```

run the server

```bash
rails s
```

## Usage
This project integrates RSwag. You can go to the Swagger documentation at
`localhost:3000/api-docs`

## Testing
This project integrates RSpec
```bash
rspec
```
For view the coverage
```bash
open coverage/index.html
```
---