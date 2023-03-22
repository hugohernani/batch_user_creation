# Users Batch

 > This project allows for upload a csv file so that users will be created by parsing each row in the file.
 > Once the row is processed the (successful or failed) result is pushed back from server to client through websocket (ActionCable)
 > orchestrated by **turbo** stream and frames.

#### It's available at https://pacific-thicket-19529.herokuapp.com

### How to run it

it's built with **Docker** in mind. This allows the project to be up and running by easily running `docker-compose` command:

```zsh
docker-compose up
```

If it's the first it's being running you may need to create and migrate the database. i.e.:

```
docker exec batch_user_creation-web-1 bin/rails db:create db:migrate
```

If you need to, you may also run each dependent service (i.e. postgresql and redis databases, sidekiq worker) manually and then run rails server as usual. Check config files to see which database user and ports you should run each server so they talk to each other. This currently follows out of box configuration. Also, check system requirements below to use dependent tools

### System Specification

* Ruby Version: 3.1.2

* Rails Version: 7.0.4.3

* Postgresql server version: 12

* Redis server version: 6.2

* Check gemset for each required version

* Project uses selenium web driver for feature/integration tests. It relies on chrome. You should have a stable chromium package installed on your system

