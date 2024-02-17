<h1 align="center">Audionook</h1>
<h3 align="center">A Free Audiobook Manager and Player</h3>

<br/>

<p align="center">
<img alt="Logo Banner" src="https://raw.githubusercontent.com/aclank/audionook/main/web/flutter/assets/images/home_logo.png"/>

## About this project
This project aims to be a free audiobook manager, server, and player similar to apps like Jellyfin or Plex. This repository contains all the code for Audionook. I'm a solo dev who has been working on this as a passion project for a while and I'm teaching myself as I go. As a result it may not work for everyone and may be unstable. I tend to work on it very hard for a while, then take long breaks so enjoy but please keep that in mind. 

This app is meant to be hosted through docker. The docker image runs an nginx webserver to serve out the UI which is written in flutter, a backend api which is written in Python3 with FastApi, and the data is stored in an SQLite databse.

There will be an Android app for accessing the server which allows for offline listening. Currently I have no plans to develop an app for IOS.

## Deployment
The Docker image can be found [here](https://hub.docker.com/r/aclank/audionook) (in the future)

I like to host it in portainer with a compose file like this:

```yaml
version: '3'
services:
  audionook:
      image: aclank/audionook:latest
      container_name: audionook
      environment:
        WATCHFILES_FORCE_POLLING: true
        SECRET_KEY: ${SECRET_KEY}
        WIKI_USER_AGENT: ${WIKI_USER_AGENT}
      volumes:
        - /path/to/audiobooks:/app/stacks
        # Optional Mounts for data persitence
        - /path/to/db:/app/db
        - /path/to/logs:/app/logs
        # Optional txt file with preselected ISBNs to help gather metadata
        - /path/to/isbnoverrides.txt:/app/stacks/isbnoverrides.txt
      ports:
        - public-port:80
```

The available environment variables are:

| Key | Description |
| --- | --- |
| SECRET_KEY | A key for the SQLite database. Has no default. |
| ENVIRON_LOGLEVEL | Defaults to `info`, can be `debug`. `debug` would print more stuff into the logs. | 
| WIKI_USER_AGENT | An optional http header for getting some metadata about authors. Syntax for the Wiki User Agent is like this <br/> (The app is built with pip wikipedia-api==0.6.0 so that part needs to stay the same): <br/> `<api-name>/<api-version> (<your-host-domain>; <your-email>) wikipedia-api/0.6.0` <br/> `scrivapi/0.01 (example.domain.com; your-email@gmail.com) wikipedia-api/0.6.0` | 

If not using portainer's stacks and environment variable stuff then replace the ${VARIABLEs} with your values.

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

<h1 align="center">Development</h1>

From here down the README needs improvement.
## Generate docker images and deploy compose files on portainer
This is just how I like to build and deploy the server locally. Feel free to do it differently.

- Download the repo.

- Setup and start a python venv or use something like poetry.

- For python's venv:

```python
python3 -m virtualenv .venv
source .venv/bin/activate
pip install -r ./requirements/common.txt -r ./scrivapi/requirements/develop.txt
```

- `make tarball-dev` (or prod)

- In Portainer -> Images -> Build a new image -> Upload

- Set the container name `your/container_name`

- Select file (`audionook_dev.tar` was generated in the `./docker` folder from the make command)

- Build the image (sometimes I have to build the prod image twice because it'll fail with: `Unexpected token < blabla`)

- In Portainer -> Stacks -> Add stack -> copy/ paste `docker-compose-dev.yml`

- \+ Add an environment variable * 3 `SECRET_KEY`, `WIKI_USER_AGENT`, `ENVIRON_LOGLEVEL`

- For the dev stack to work you need to mount many extra things in the yaml file: 

```yaml
version: '3'
services:
  audionook_dev:
    image: <your>/<image_name>:latest
    container_name: audionook_dev
    environment:
      WATCHFILES_FORCE_POLLING: true
      SECRET_KEY: ${SECRET_KEY}
      WIKI_USER_AGENT: ${WIKI_USER_AGENT}
      ENVIRON: ${ENVIRON}
      ENVIRON_LOGLEVEL: ${ENVIRON_LOGLEVEL}
    volumes:
      - /path/to/audiobooks:/app/stacks
      # Optional Mounts for data persitence
      - /path/to/db/dev:/app/db
      - /path/to/logs/dev:/app/logs
      # Optional txt file with preselected ISBNs to help gather metadata
      - /path/to/isbnoverrides.txt:/app/stacks/isbnoverrides.txt
      # Required extra mounts for dev container
      # scrivapi
      - /path/to/repo/src:/app/src
      - /path/to/repo/bin/run_dev.sh:/app/bin/run_dev.sh
      - /path/to/repo/bin/dev-supervisord.conf:/etc/supervisor/conf.d/supervisord.conf
      - /path/to/repo/docker/.env:/app/bin/.env
      # nginx
      - /path/to/repo/web/nginx/nginx.conf:/etc/nginx/nginx.conf
      - /path/to/repo/web/nginx/error-modules:/etc/nginx/error-modules
      - /path/to/repo/web/nginx/sites-available/dev-audionook.conf:/etc/nginx/sites-available/default
      - /path/to/repo/web/nginx/sites-enabled:/etc/nginx/sites-enabled
      # web
      - /path/to/repo/web/flutter/build/web:/var/www/audionook
      - /path/to/repo/web/html:/var/www/default
    ports:
      - public-port:80
```

- Update the stack

- Note - There is an extra `ENVIRON` environment variable which can be `production` (default) or `dev` which just turns off the fastapi docs pages when in production mode. Setting this var on a production build of the container will still not enable the docs page without tweaking `./src/app.py`

- Note - `./bin/run_dev.sh` tries to source that `./docker/.env` file but portainer vars seem to override whatever is in .env so it is only there for running the uvicorn server manually outside of docker (like with the `./bin/run_local.sh` or `./bin/run_local.bat` for example)

## Alembic Database Migrations
I am terrible at database migrations. Here are some notes I made at some point that might help.

https://www.jeffastor.com/blog/pairing-a-postgresql-db-with-your-dockerized-fastapi-app/

`sudo docker exec -it <container_name> bash`

`alembic revision -m "create_main_tables"`

this will make a file in ./src/db/migrations/versions/####_"whatever_was_in_quotes".py for creating the main tables.

Add stuff in there

`alembic upgrade head`<br/>
`alembic downgrade head`

## Public Access
Port foward your `<public-port>` on your router. If you own a domain name you could setup a reverse proxy in the same or another portainer stack and give your server a proper url/ ssl. Or any other way of doing that. Otherwise you can access the site at `http://<your-public-ip>:<public-port>`
