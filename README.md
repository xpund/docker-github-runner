# Github Runner on Docker

Self hosted runner on docker container

## Usage

You don't need to change **docker-compose.yml** file. Just copy and use the file from repository.
However, you need to create a **.env** file.

*Please check **.env.example** file.*

When the 2 files are ready, run below command
```bash
docker-compose up -d
```
OR
```bash
docker compose up -d
```

#### docker-compose.yml
```yml
version: "3"

services:
  github-runner:
    image: mainto/github-runner:latest
    privileged: true
    volumes:
      - github-runner-volume:/runner
    environment:
      - GIT_URL=${GIT_URL}
      - TOKEN=${TOKEN}
    restart: unless-stopped
volumes:
  github-runner-volume: 
```

#### .env

```shell
# Project name must be unique on your docker host (for volume)
COMPOSE_PROJECT_NAME=github-runner

# Github Repository - ex) https://github.com/{USER}/{REPO}
GIT_URL=https://github.com/mainto/docker-github-runner

# You can get a token here: 
# https://github.com/{USER}/{REPO}/settings/actions/runners/new
TOKEN=ABCDEF012345678900SAMPLETOKEN
```

#### Environments
All 3 environment values are required

| COMPOSE_PROJECT_NAME |
|:-----|
| This is project name. It must be unique on your docker host. It will prevent to use same volume. |

| GIT_URL |
|:-----|
| This is your Github Repository URL <br> ex) https://github.com/mainto/docker-github-runner |

| TOKEN |
|:-----|
|You can get a token here: https://github.com/{USER}/{REPO}/settings/actions/runners/new <ul><li> TOKEN will be expired after few minutes. </li><li> After runner is registered as github runner, you don't need to get new TOKEN. Credentials will be stored on docker volume. </li><li> When restart this docker container, stored credentials will be reused.|