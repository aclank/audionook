<h1 align="center">Audionook</h1>
<h3 align="center">A Free Audiobook Manager and Player</h3>

<br/>

<p align="center">
<img alt="Logo Banner" src="https://raw.githubusercontent.com/aclank/audionook/main/web/flutter/assets/images/home_logo.png"/>

## About this project
This project aims to be a free audiobook manager, server, and player similar to apps like Jellyfin or Plex. This repository will contain all the code for Audionook. I'm a solo dev who has been working on this as a passion project for a while and I'm teaching myself as I go. As a result it may not work for everyone and may be unstable.

This app is meant to be hosted through docker. The docker image runs an nginx webserver to serve out the UI which is written in flutter, a backend api which is written in Python with FastApi, and the data is stored in an SQLite databse.

There will be an Android app for accessing the server which allows for offline listening. Currently I have no plans to develop an app for IOS.

## Deployment
The Docker image can be found [here](https://hub.docker.com/r/aclank/audionook) (in the future)

I like to host it in [Portainer (install guide)](https://docs.portainer.io/start/install-ce/server/docker/linux) with a compose file like this:<br/>- Code here is possibly out of date. Refer to: [docker-compose.yml](https://github.com/aclank/audionook/blob/main/docker/docker-compose.yml)

```yaml
version: '3'
services:
  audionook:
    image: aclank/audionook:latest
    container_name: audionook
    environment:
      SECRET_KEY: ${SECRET_KEY}
      WIKI_USER_AGENT: ${WIKI_USER_AGENT}
    volumes:
      - /path/to/audiobooks:/app/stacks
      # Optional Mounts for data persistence
      - /path/to/db:/app/db
      - /path/to/logs:/app/logs
      # Optional .txt file with preselected ISBNs to help gather metadata. Could already exist in
      # /path/to/audiobooks folder rather than directly linking like this.
      - /path/to/ISBNoverrides.txt:/app/stacks/ISBNoverrides.txt
    ports:
      - public-port:80
```

The available environment variables are:

| Key | Description |
| --- | --- |
| SECRET_KEY | A key for the SQLite database. Has no default. |
| ENVIRON_LOGLEVEL | Defaults to `info`, can be `debug`. `debug` would print more stuff into the fastapi logs. | 
| WIKI_USER_AGENT | An optional http header for getting some metadata about authors. Syntax for the Wiki User Agent is like this<br/>(The app is built with pip wikipedia-api==0.6.0 so that part needs to stay the same): <br/>`<api-name>/<api-version> (<your-host-domain>; <your-email>) wikipedia-api/0.6.0` <br/> `scrivapi/0.01 (example.domain.com; your-email@gmail.com) wikipedia-api/0.6.0` | 

Be sure to change the `/path/to/<things>` for wherever your audiobooks are stored locally and where you would like to persist the database ect. The only one you have to have is the first for audiobooks, the rest are optional. Also be sure to update the `public-port` and pick a free port to host the app on. Perhaps 33000 for example.

If not using Portainers stacks and environment variable features then replace the ${VARIABLES} with your values directly.

Once the docker container is running you can checkout the website at `http://localhost:public-port`

Create an admin account and generate the library based off the books you supply. Start listening and enjoy!

## Library File Structure
At the moment this app requires a quite strict folder structure for the audio files. At the top level are `Author Name` folders and inside there should be `book-_-num-_-Title` folders (num is optional)

You can have any number of `series-_-num-_-Book Title` folders (again num is optional) which contain the book folders. 

Each book folder needs a `version-_-Type-_-v##` that holds the actual audio files. `Type` can be anything descriptive but I recommend keeping it short.

You can supply an `author-_-Author Name.jpg` and `cover-_-Book Title.jpg` in the respective author and book folders. Otherwise Audionook will try to download an image off of google (or perhaps just fallback on a placeholder. Placeholder for now)

Here is an example folder structure

TODO re-write this without using Brandon Sandersons work as the example.
```
Brandon Sanderson
  - author-_-Brandon Sanderson.jpg
  - series-_-Mistborn
    - series-_-01-_-Original Trilogy (Era One)
      - book-_-01-_-The Final Empire
        - cover-_-The Final Empire.jpg
        - version-_-mp3_v01
          - audio_files.mp3
        - version-_-Graphic Audio_v01
          - audio_files.mp3
      - book-_-02-_-The Well of Ascension
        - cover-_-The Well of Ascension.jpg
        - version-_-mp3_v01
          - audio_files.mp3
    - series-_-02-_-Wax and Wayne Series (Era Two)
      - book-_-04 - The Alloy of Law
        - cover-_-The Alloy of Law.jpg
        - version-_-mp3_v01
          - audio_files.mp3
      - book-_-05 - Shadows of Self
        - cover-_-Shadows of Self.jpg
        - version-_-m4b_v01
          - audio_files.m4b
  - book-_-Warbreaker
    - cover-_-Warbreaker
    - version-_-mp3_v01
      - audio_files.mp3
```

This would have 6 unique versions for 5 different books. Some of the books are part of a series (Mistborn Era One) which is itself part of a series (Mistborn) while some books are standalone (Warbreaker)

The app requires this folder structure so that the books can be organized by author and series which is a way I strongly prefer to browse my library over other audiobook managers I've tried which put books into a long list and that's it. 

## Database file
This app currently uses an SQLite .db file to store information about the books in your library and users login info and watch history. *I am not a security expert* so please don't re-use passwords from other accounts with this app. If you aren't using a password manager, start using one. I like [BitWarden](https://bitwarden.com/) at the moment.

You can persist the database by mounting a directory to `/app/db`. Please be careful of messing with the `tolemledger.db` that gets created. If anything breaks locally with your database I find it quite difficult to diagnose/ fix issues and database migrations are a headache. I have lost listening history by messing with these files. That said, I like to use [this](https://sqlitebrowser.org/dl/) app for browsing the .db file through a gui. If you are comfortable with sqlite commands from a CLI that's also an option. 

## Log Files
You can mount a folder to `/app/logs` if you want to see the logs from nginx and fastapi. You should get a folder for each and should mainly see output in `audionook-access.log` and `audionook-error.log` from nginx, and in `scrivapi.log` from fastapi. These logs should also be getting sent to docker either way.

The docker environment variable `ENVIRON_LOGLEVEL` can be set to either `info` (default) or `debug` which will effect how much fastapi puts into its log file.

Consider keeping an eye on the `audionook-access.log` if you enable access to this server from outside your home network. If you see attempts to access the site that you don't like, consider investigating firewalls or some other security for your network. Exposing ports can be dangerous and I'm no security expert. Be safe.


<h1 align="center">Development</h1>
This is just how I like to build and deploy the server locally while I work and is as much a reference for myself as anything. Feel free to do it differently.

## Generate docker images and deploy compose files on portainer

- Download the repo.

- Setup and start a python venv or use something like poetry.

- For python's venv:

```bash
# When first setting up
cd /path/to/repo
python3 -m virtualenv .venv
source .venv/bin/activate
pip install -r ./requirements/common.txt -r ./scrivapi/requirements/develop.txt

# Afterwards
cd /path/to/repo
source .venv/bin/activate
```

- For Poetry - [Matt Cale reference](https://dev.to/mattcale/pyenv-poetry-bffs-20k6)

```bash
# When first setting up 
cd /path/to/repo
poetry config virtualenvs.in-project true
poetry init -n
poetry shell
poetry add fastapi==0.103.1
# poetry add - all the stuff from requirements.txt and develop.txt

# Afterwards
cd /path/to/repo
poetry shell
```

- Do some awesome work on the project.

- `make tarball-dev` (or prod)

- In Portainer -> Images -> Build a new image -> Upload

- Set the container name `your/container_name`

- Select file (`audionook_dev.tar` was generated in the `./docker` folder from the make command)

- Build the image<br/>- sometimes I have to build the prod image twice because it'll fail with: `Unexpected token '&lt;', "[&lt;!DOCTYPE "... is not valid JSON`

- In Portainer -> Stacks -> Add stack -> copy/ paste `docker-compose-dev.yml`

- \+ Add an environment variable * 3 `SECRET_KEY`, `WIKI_USER_AGENT`, `ENVIRON_LOGLEVEL`

- For the dev stack to work you need to mount many extra things in the yaml file: <br/>- Code here is possibly out of date. Refer to: [docker-compose-dev.yml](https://github.com/aclank/audionook/blob/main/docker/docker-compose-dev.yml)

```yaml
version: '3'
services:
  audionook_dev:
    image: <your>/<image_name>:latest
    container_name: audionook_dev
    environment:
      SECRET_KEY: ${SECRET_KEY}
      WIKI_USER_AGENT: ${WIKI_USER_AGENT}
      ENVIRON_LOGLEVEL: ${ENVIRON_LOGLEVEL}
      ENVIRON: ${ENVIRON}
    volumes:
      - /path/to/audiobooks:/app/stacks
      # Optional Mounts for data persitence
      - /path/to/db/dev:/app/db
      - /path/to/logs/dev:/app/logs
      # Optional .txt file with preselected ISBNs to help gather metadata. Could already exist in
      # /path/to/audiobooks folder rather than directly linking like this.
      - /path/to/ISBNoverrides.txt:/app/stacks/ISBNoverrides.txt
      # Required extra mounts for dev container
      # scrivapi
      - /path/to/repo/src:/app/src
      - /path/to/repo/bin/run_dev.sh:/app/bin/run_dev.sh
      - /path/to/repo/bin/supervisord-dev.conf:/etc/supervisor/conf.d/supervisord.conf
      - /path/to/repo/docker/dev.env:/app/bin/.env
      # nginx
      - /path/to/repo/web/nginx/nginx.conf:/etc/nginx/nginx.conf
      - /path/to/repo/web/nginx/error-modules:/etc/nginx/error-modules
      - /path/to/repo/web/nginx/sites-available/audionook-dev.conf:/etc/nginx/sites-available/default
      - /path/to/repo/web/nginx/sites-enabled:/etc/nginx/sites-enabled
      # web
      - /path/to/repo/web/flutter/build/web:/var/www/audionook
      - /path/to/repo/web/html:/var/www/default
    ports:
      - public-port:80
```

- Update the stack

- Note - There is an extra `ENVIRON` environment variable which can be `production` (default) or `dev` and turns off the fastapi docs pages when in production mode. Setting this var on a production build of the container will still not enable the docs page without tweaking `./src/app.py` and `./web/nginx/sites-available/audionook.conf`

- Note - `./bin/run_dev.sh` tries to source the `./docker/.env` file but portainer vars seem to override whatever is in .env so it is only there for running the uvicorn server manually outside of docker (like with the `./bin/run_local.sh` or `./bin/run_local.bat` for example)

---

If you dont like using compose files there are also [Makefile commands](https://github.com/aclank/audionook/blob/main/Makefile) for building and starting the docker container. Some examples:

```make
docker-run:
	@docker build -f docker/Dockerfile -t aclank/audionook .
	@docker run --rm --name audionook \
	-p 33000:80 \
	--env-file docker/.env \
	-v $(shell pwd)/../stacks:/app/stacks \
	-v $(shell pwd)/db/prod:/app/db \
	-v $(shell pwd)/logs/prod:/app/logs \
	aclank/audionook

docker-run-dev:
	@docker build -f docker/Dockerfile-dev -t aclank/audionook_dev .
	@docker run --rm --name audionook_dev \
	-p 32999:80 \
	-v $(shell pwd)/../stacks:/app/stacks \
	-v $(shell pwd)/db/dev:/app/db \
	-v $(shell pwd)/logs/dev:/app/logs \
	-v $(shell pwd)/src:/app/src \
	-v $(shell pwd)/bin/run_dev.sh:/app/bin/run_dev.sh \
	-v $(shell pwd)/bin/supervisord-dev.conf:/etc/supervisor/conf.d/supervisord.conf \
	-v $(shell pwd)/docker/dev.env:/app/bin/.env \
	-v $(shell pwd)/web/nginx/nginx.conf:/etc/nginx/nginx.conf \
	-v $(shell pwd)/web/nginx/error-modules:/etc/nginx/error-modules \
	-v $(shell pwd)/web/nginx/sites-available/audionook-dev.conf:/etc/nginx/sites-available/default \
	-v $(shell pwd)/web/nginx/sites-enabled:/etc/nginx/sites-enabled \
	-v $(shell pwd)/web/flutter/build/web:/var/www/audionook \
	-v $(shell pwd)/web/html:/var/www/default \
	aclank/audionook_dev
```

- Note - I'm currently using a `.env` file to source in the environment variables for the dev build inside of the `./bin/run_dev.sh` file, but for the production build they are sourced in the `docker run` command. Normally for the production build I would expect users to set the vars manually with a `-e VAR=value \` line perhaps when not using the compose method.

Hopefully these examples are enough to get someone started working on the project.

## Alembic Database Migrations
I am terrible at database migrations. Here are some notes I made at some point that might help.

[Jeff Astor page I referenced a bunch](https://www.jeffastor.com/blog/pairing-a-postgresql-db-with-your-dockerized-fastapi-app/)

- `sudo docker exec -it <container_name> bash`

- `alembic revision -m "create_main_tables"`

- This will make a file in `./src/db/migrations/versions/####_"whatever_was_in_quotes".py` for creating the main tables.

- Add some migration stuff to the .py file.

- `alembic upgrade head`<br/>
- `alembic downgrade head`

## Public Access
Port foward your `<public-port>` on your router. If you own a domain name you could setup a reverse proxy ([I like NPM](https://nginxproxymanager.com/)) in the same or another portainer stack and give your server a proper url/ ssl. Or any other way of handling ssl would be good to do. Otherwise you can access the site at `http://<your-public-ip>:<public-port>`

You could perhaps set the public port on the docker container to 80 and not need to specify a `:<public-port>` in your public url but I don't think I would recommend that, it seems unsafe and you would still need to forward port 80 on your router. Using a reverse proxy which can handle ssl and forward to another port (the `<public-port>` you set) on your home network seems at least slightly safer. Either way **proceed at your own risk**.
