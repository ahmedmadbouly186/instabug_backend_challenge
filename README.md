# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

# steps to connect the database

- download docker image

## Redis

### Building

```
docker build -t redis_image ./redis/.
docker run  rails --name redis_image -p 6400:6400 -d redis_image
```

Running the Jobs
Now that the job is in the queue, we need to run the Sidekiq worker to execute the job. Open another terminal window and execute:

bundle exec sidekiq

### Testing

```
docker exec -it redis_app redis-cli -p 6400
```

# elasticsearch

docker network create system
docker pull docker.elastic.co/elasticsearch/elasticsearch-wolfi:8.17.0
docker run --name es01 -p 9125:9125 -m 1GB -d docker.elastic.co/elasticsearch/elasticsearch:8.17.0

- reconnect
  docker exec -it es01 /bin/bash

# How to run?

- rails server
- bundle exec sidekiq
