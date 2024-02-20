<h1 align="center">Audionook</h1>
<h3 align="center">A Free Audiobook Manager and Player</h3>

<br/>

<p align="center">
<img alt="Logo Banner" src="https://raw.githubusercontent.com/aclank/audionook/main/web/flutter/assets/images/home_logo.png"/>

## About this project
This project aims to be a free audiobook manager, server, and player similar to apps like Jellyfin or Plex. This repository will contain all the code for Audionook. I'm a solo dev who has been working on this project on and off (mostly off) since around the end of 2018 and I'm teaching myself as I go. As a result it may not work for everyone and may be unstable.

This project is meant to be hosted through docker. The docker image runs an [NGINX](https://www.nginx.com/) webserver to serve out the UI which is written in [Dart](https://dart.dev/) and  [Flutter](https://flutter.dev/), a backend api which is written in Python with [FastApi](https://fastapi.tiangolo.com/), and the data is stored in an [SQLite](https://www.sqlite.org/index.html) database. I've played around with various options for each of these aspects of the project and landed on this architecture for reasons, but I'm always open to other solutions!

There will be an Android app for accessing the server which allows for offline listening. Currently I have no plans to develop an app for IOS.

## Deployment
The Docker image can be found [here](https://hub.docker.com/r/aclank/audionook) (in the future)

I like to host it in [Portainer (install guide)](https://docs.portainer.io/start/install-ce/server/docker/linux) with a compose file like this:
<br/>
\- Code here is possibly out of date. Refer to: [docker-compose.yml](https://github.com/aclank/audionook/blob/main/docker/docker-compose.yml)

```yaml
version: '3'
services:
  audionook:
    image: aclank/audionook:latest
    container_name: audionook
    environment:
      TZ: <your>/<timezone>
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
| WIKI_USER_AGENT | [An optional http header](https://meta.wikimedia.org/wiki/User-Agent_policy) for getting some metadata about authors. Syntax for the Wiki User Agent is like this <br/> (The app is built with pip wikipedia-api==0.6.0 so that part needs to stay the same): <br/> `<api-name>/<api-version> (<your-host-domain>; <your-email>) wikipedia-api/0.6.0` <br/> `scrivapi/0.01 (example.domain.com; your-email@gmail.com) wikipedia-api/0.6.0` | 
| TZ | [Time Zone Codes.](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) Optional but recommended. For now just effects timestamp in the logs. |



Be sure to change the `/path/to/<things>` for wherever your audiobooks are stored locally and where you would like to persist the database ect. The only one you have to have is the first for audiobooks, the rest are optional. Also be sure to update the `public-port` and pick a free port to host the app on. Perhaps 33000 for example.

If not using Portainers stacks and environment variable features then replace the ${VARIABLES} with your values directly.

Once the docker container is running you can checkout the website at `http://localhost:public-port`

Create an admin account and generate the library based off the books you supply. Start listening and enjoy!

## Library File Structure
At the moment this app requires a quite strict folder structure for the audio files. At the top level are `Author Name` folders and inside there should be `book-_-num-_-Title` folders. Num is optional. `book-_-Title` would also be valid.

`-_-` is used as a unique delimiter that I do not expect to ever be in a book or series title. Famous last words..

You can have any number of `series-_-num-_-Book Title` folders (again num is optional) which contain the book folders. 

Each book folder needs a `version-_-Type-_-v##` that holds the actual audio files. `Type` can be anything descriptive but I recommend keeping it short. I use things like 'mp3' or 'Graphic Audio'. Maybe you could put the name of the narrator if you like? No promises that will fit in the dropdown for selecting book versions.

You can supply an `author-_-Author Name.jpg` and `cover-_-Book Title.jpg` in the respective author and book folders. Otherwise Audionook will try to download an image off of google (or perhaps just fallback on a placeholder. Placeholder for now)

Here is an example folder structure

```sh
. # /path/to/audiobooks/
└── Brandon Sanderson                                     # Author folder.
    ├── author-_-Brandon Sanderson.jpg                    # (Optional) Headshot of author.
    ├── series-_-Mistborn                                 # Series folder.
    │   │
    │   ├── series-_-01-_-Original Trilogy (Era One)      # Sub-series folder.
    │   │   │
    │   │   ├── book-_-01-_-The Final Empire              # Book folder.
    │   │   │   ├── cover-_-The Final Empire.jpg          # (Optional) Cover art for book.
    │   │   │   │
    │   │   │   ├── version-_-mp3_v01                     # Version folder.
    │   │   │   │   ├── chapter_01.mp3                    # Audio files.
    │   │   │   │   └── chapter_02.mp3
    │   │   │   │
    │   │   │   ├── version-_-mp3_v02                     # A second version of the same 'Type'.
    │   │   │   │   ├── chapter_01.mp3                    # Audio files.
    │   │   │   │   └── chapter_02.mp3
    │   │   │   │
    │   │   │   └── version-_-Graphic Audio_v01           # Version folder of a second type.
    │   │   │       ├── chapter_01.mp3                    # Audio files.
    │   │   │       └── chapter_02.mp3
    │   │   │
    │   │   └── book-_-02-_-The Well of Ascension         # Book folder.
    │   │       ├── cover-_-The Well of Ascension.jpg     # (Optional) Cover art for book.
    │   │       │
    │   │       └── version-_-mp3_v01                     # Version folder.
    │   │           ├── chapter_01.mp3                    # Audio files.
    │   │           └── chapter_02.mp3
    │   │
    │   └── series-_-02-_-Wax and Wayne Series (Era Two)  # Sub-series folder.
    │       │
    │       └── book-_-04 - The Alloy of Law              # Book folder.
    │           ├── cover-_-The Alloy of Law.jpg          # (Optional) Cover art for book.
    │           │
    │           └── version-_-mp3_v01                     # Version folder.
    │               ├── chapter_01.mp3                    # Audio files.
    │               └── chapter_02.mp3
    │
    └────── book-_-Warbreaker                             # Book folder.
            ├── cover-_-Warbreaker                        # (Optional) Cover art for book.
            │
            └── version-_-mp3_v01                         # Version folder.
                ├── chapter_01.mp3                        # Audio files.
                └── chapter_02.mp3
```

This would have 6 unique versions for 5 different books. Some of the books are part of a series (Mistborn Era One) which is itself part of a series (Mistborn) while some books are standalone (Warbreaker)

The app requires this folder structure so that the books can be organized by author and series which is a way I strongly prefer to browse my library over other audiobook managers I've tried which put books into a long list and that's it. It should provide a lot of flexibility to have the app organize books however you like. If you do not care about series you can just have `book-_-` folders below each `Author Name` folder. Or you can nest them inside \<x> number of `series-_-` folders.

Disclaimer - I plan to support re-organizing books and series from within the app, but it requires moving files on disk and updating db paths accordingly. This feature is not fully implemented so for now it's best to spend a minute up front organizing your files before initializing the app. I realize this can be tedious so I will probably revisit how the api expects files to be organized at some point.

## Public Access
Port foward your `<public-port>` on your router. If you own a domain name you could setup a reverse proxy ([I like NPM](https://nginxproxymanager.com/)) in the same or another portainer stack and give your server a proper url/ ssl. Or any other way of handling ssl would be good to do. Otherwise you can access the site at `http://<your-public-ip>:<public-port>`

You could perhaps set the public port on the docker container to 80 and not need to specify a `:<public-port>` in your public url but I don't think I would recommend that, it seems unsafe and you would still need to forward port 80 on your router. Using a reverse proxy which can handle ssl and forward to another port (the `<public-port>` you set) on your home network seems at least slightly safer.

Either way **proceed at your own risk**.

## Database file
This app currently uses an SQLite .db file to store information about the books in your library and users login info and watch history. *I am not a security expert* so please don't re-use passwords from other accounts with this app. If you aren't using a password manager, start using one. I like [BitWarden](https://bitwarden.com/) at the moment.

You can persist the database by mounting a directory to `/app/db`. Please be careful of messing with the `tolemledger.db` that gets created. If anything breaks locally with your database I find it quite difficult to diagnose/ fix issues and database migrations are a headache. I have lost listening history by messing with these files. That said, I like to use [this](https://sqlitebrowser.org/dl/) app for browsing the .db file through a gui. If you are comfortable with sqlite commands from a CLI that's also an option. 

## Log Files

[fastapi log config](https://github.com/aclank/audionook/blob/main/src/config/info-logs.ini)

You can mount a folder to `/app/logs` if you want to see the logs from nginx and fastapi. You should get a folder for each and should mainly see output in `audionook-access.log` and `audionook-error.log` from nginx, and in `scrivapi.log` from fastapi. These logs should also be getting sent to docker either way.

The docker environment variable `ENVIRON_LOGLEVEL` can be set to either `info` (default) or `debug` which will effect how much fastapi puts into its log file.

Consider keeping an eye on the `audionook-access.log` if you enable access to this server from outside your home network. If you see attempts to access the site that you don't like, consider investigating firewalls or some other security for your network. Exposing ports can be dangerous and I'm no security expert. Be safe.

<br/>
<br/>

<h1 align="center">Development</h1>
This is how I like to build and deploy the server locally while I work and is as much a reference for myself as anything. Feel free to do it differently.

<br/>

## Prep local environmant

- Download the repo.

- I use [Android Studio](https://developer.android.com/studio) to get Android emulators installed.

- I think [VS Code](https://code.visualstudio.com/) usually helps me install things for [Flutter](https://docs.flutter.dev/get-started/install/windows/mobile?tab=vscode).

- Make sure Python3 is installed (I'm using 3.11.0 at the moment), I like to use [pyenv](https://github.com/pyenv/pyenv) for that.

- Setup and start a python venv or use something like [Poetry](https://github.com/python-poetry/poetry).

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

## Generate Docker images and deploy compose files with Portainer

[docker files](https://github.com/aclank/audionook/blob/main/docker)

- `make tarball-dev` (or `make tarball`)

```make
tarball:
	@rm -f ./docker/audionook.tarball
	@tar --exclude='*.pyc' \
	-cvf docker/audionook.tar \
	--transform 'flags=r;s|docker/Dockerfile|Dockerfile|' docker/Dockerfile \
	--transform 'flags=r;s|docker/.dockerignore|.dockerignore|' docker/.dockerignore \
	requirements \
	src/scrivapi \
	web/html \
	web/nginx \
	web/flutter/build/web \
	bin/run.py \
	bin/supervisord.conf
```

- In Portainer -> Images -> Build a new image -> Upload

- Set the image name `<your>/<image_name>`. 

- Select file (`audionook_dev.tar` was generated in the `/docker` folder from the `make` command)

- Build the image
<br/>
Note - Sometimes I have to build the prod image twice because it'll fail with: `Unexpected token '&lt;', "[&lt;!DOCTYPE "... is not valid JSON`

- In Portainer -> Stacks -> Add stack -> copy/ paste `docker-compose-dev.yml`

- \+ Add an environment variable * 3 `SECRET_KEY`, `WIKI_USER_AGENT`, `ENVIRON_LOGLEVEL`

- For the dev stack to work you need to mount many extra things in the yaml file:
<br/>
\- Code here is possibly out of date. Refer to: [docker-compose-dev.yml](https://github.com/aclank/audionook/blob/main/docker/docker-compose-dev.yml)

```yaml
version: '3'
services:
  audionook_dev:
    image: <your>/<image_name>:latest
    container_name: audionook_dev
    environment:
      TZ: <your>/<timezone>
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
      - /path/to/repo/src/scrivapi:/app/src/scrivapi
      - /path/to/repo/bin/run_dev.py:/app/bin/run.py
      - /path/to/repo/docker/dev.env:/app/bin/.env
      # nginx
      - /path/to/repo/web/nginx/nginx.conf:/etc/nginx/nginx.conf
      - /path/to/repo/web/nginx/error-modules:/etc/nginx/error-modules
      - /path/to/repo/web/nginx/sites-available/audionook-dev.conf:/etc/nginx/sites-available/default
      - /path/to/repo/web/nginx/sites-enabled:/etc/nginx/sites-enabled
      # web
      - /path/to/repo/web/flutter/build/web:/var/www/audionook
      - /path/to/repo/web/html:/var/www/default
      # startup
      - /path/to/repo/bin/supervisord.conf:/etc/supervisor/conf.d/supervisord.conf
    ports:
      - public-port:80
```

- Update the stack

- Note - There is an extra `ENVIRON` environment variable which can be `production` (default) or `dev` and turns off the fastapi docs pages when in production mode. Setting this var on a production build of the container will still not enable the docs page without tweaking [/src/app.py](https://github.com/aclank/audionook/blob/main/src/app.py) and [/web/nginx/sites-available/audionook.conf](https://github.com/aclank/audionook/blob/main/web/nginx/sites-available/audionook.conf)

- Note - [/bin/run.py](https://github.com/aclank/audionook/blob/main/bin/run.py) sources the [/docker/.env](https://github.com/aclank/audionook/blob/main/docker/template.env) file but skips if the envrionment variable has already been set. It is only there for running the uvicorn server manually outside of docker (like with the [/bin/run_local.py](https://github.com/aclank/audionook/blob/main/bin.run_local.py))

## Generate Docker image and run container

If you dont like using compose to manage your containers then there are [Makefile commands](https://github.com/aclank/audionook/blob/main/Makefile) for building and starting the docker container that way.
<br/>
To use Makefile commands on Windows following [this](https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows) or [this](https://www.reddit.com/user/lethinhrider/comments/1196bnx/how_to_install_and_use_chocolatey_to_install/) rabbit hole worked for me. Be careful about setting 'Execution-Policy's in general.

Some examples:

```make
docker-run:
	@docker build -f docker/Dockerfile -t <your>/<image_name> .
	@docker run --rm --name audionook \
	-p 33000:80 \
	--env-file docker/.env \
	-v $(shell pwd)/../stacks:/app/stacks \
	-v $(shell pwd)/db/prod:/app/db \
	-v $(shell pwd)/logs/prod:/app/logs \
	<your>/<image_name>

docker-run-dev:
	@docker build -f docker/Dockerfile-dev -t <your>/<image_name_dev> .
	@docker run --rm --name audionook_dev \
	-p 32999:80 \
	-v $(shell pwd)/../stacks:/app/stacks \
	-v $(shell pwd)/db/dev:/app/db \
	-v $(shell pwd)/logs/dev:/app/logs \
	-v $(shell pwd)/src:/app/src \
	-v $(shell pwd)/bin/run_dev.py:/app/bin/run_dev.py \
	-v $(shell pwd)/bin/supervisord.conf:/etc/supervisor/conf.d/supervisord.conf \
	-v $(shell pwd)/docker/dev.env:/app/bin/.env \
	-v $(shell pwd)/web/nginx/nginx.conf:/etc/nginx/nginx.conf \
	-v $(shell pwd)/web/nginx/error-modules:/etc/nginx/error-modules \
	-v $(shell pwd)/web/nginx/sites-available/audionook-dev.conf:/etc/nginx/sites-available/default \
	-v $(shell pwd)/web/nginx/sites-enabled:/etc/nginx/sites-enabled \
	-v $(shell pwd)/web/flutter/build/web:/var/www/audionook \
	-v $(shell pwd)/web/html:/var/www/default \
	<your>/<image_name_dev>
```

- Note - I'm currently using a `.env` file to source in the environment variables inside of [/bin/run.py](https://github.com/aclank/audionook/blob/main/bin/run.py), but for they prioritize envrinment variables sourced by docker either with `--env-file docker/.env` in this case or environment: in the compose files. You could also set environment vars manually with `-e VAR=value \` lines between the `-p` and `-v` flags but I prefer to keep them in a `.env` file so that at least the `SESCRET_KEY` is slightly obscured.

Hopefully these examples are enough to get someone started working on the project.

## Alembic Database Migrations
I am terrible at database migrations. Here are some notes I made at some point that might help.

[Jeff Astor page I referenced a bunch](https://www.jeffastor.com/blog/pairing-a-postgresql-db-with-your-dockerized-fastapi-app/)

- `sudo docker exec -it <container_name> bash`

- `alembic revision -m "create_main_tables"`

- This will make a file in `/src/db/migrations/versions/####_"whatever_was_in_quotes".py` for creating the main tables.

- Add some migration stuff to the .py file.

- `alembic upgrade head`<br/>
- `alembic downgrade head`


<br/>
<br/>

<h1 align="center">Project Architecture</h1>
Here I'll try and go into how different parts of the project are structured and maybe why I've made certain decisions about things.

<br/> 
Some of the links below will be broken until I get all my files onto github soon tm.

<br/>

## NGINX

[web/nginx](https://github.com/aclank/audionook/blob/main/web/nginx)

The main internal port for the container is port 80 which is watched by an NGINX Webserver. Most of the config for this can be found in [web/nginx/sites-available/audionook.conf](https://github.com/aclank/audionook/blob/main/web/nginx/sites-available/audionook.conf)

### Locations:
- `/` Traffic for `http://local-ip/` gets directed into [web/flutter/build/web](https://github.com/aclank/audionook/blob/main/web/flutter/build/web)

- `~ favicon.ico` hopefully I can figure out why the [HTML error pages](https://github.com/aclank/audionook/blob/main/web/html) seem to need this location block to exist but for now this ones to force the favicon.ico to show up.

There are a few manual locations that need to be proxy_passed to FastApi.
- `/scrivapi` most of the backend traffic happens here and is proxy_passed to `http://localhost:8008` which fastapi is watching
- `/health` is just a page to check if the app is running. If this location works then both nginx and fastapi need to be running so it helps confirm nothing is super broken
- `/stacks` is where all the media gets served from. It requires /auth through the api before serving anything.

The dev build gets a few extra locations for the FastApi docs pages.
- `/docs`
- `/redoc`
- `= /openapi.json` also seems to be required for the swagger page (`/docs`)

In the past I used Apache2 but at some point I switched to NGINX and don't remember if there was a specific reason. I enjoy working with NGINX's suite of tools.

Fun fact, apparently its pronounced engine-x. Who knew.

## Flutter

[web/flutter](https://github.com/aclank/audionook/blob/main/web/flutter)

I'm in the middle of re-building the front-end UI's after recently switching to FastApi so this is still in progress. In a perfect world I would have one flutter project for both the web and mobile apps but we'll see.

### Dependencies

- [Riverpod](https://pub.dev/packages/riverpod) - State management.

- It's a single page app (SPA) so I am not using a router, though I have written [something](https://github.com/aclank/audionook/blob/main/web/flutter/lib/features/nav) akin to routing so that the user can navigate backwards. 

- [just_audio](https://pub.dev/packages/just_audio) - Web and mobile audio playback.

- [Drift](https://pub.dev/packages/drift) - Android local database fto enable offline browsing and playback on the Android app.

The first iteration of this project was built in [Webix](https://webix.com/) but I preferred coding in dart and switched to it at some point.

## FastApi

[src/](https://github.com/aclank/audionook/blob/main/src)

FastApi handles interactions between the UI and the SQLite database. I have recently re-built the backend api with FastApi instead of Flask which I was using before. I've been enjoying FastApi a lot.

FastApi watches on port 8080 inside the container.

[src/scrivapi/app.py](https://github.com/aclank/audionook/blob/main/src/scrivapi/app.py) is the entry point.

### Dependencies 

- [uvicorn](https://www.uvicorn.org/) - ASGI web server.

- [SQLAlchemy](https://www.sqlalchemy.org/) - SQLite database interactions.

- [OAuth2](https://fastapi.tiangolo.com/tutorial/security/simple-oauth2/) - api authentication.

I'm still working on the api so I will update this section to be more in depth soon once I am a bit further along.

## SQLite
I've been using SQLite for most of the life of this project. I played around with [PostgreSQL](https://www.postgresql.org/) for a while but decided to go back to SQLite because it makes having a single docker image simpler to manage. 

<br/>
<br/>

<h1 align="center">Tools and links that help me with development</h1>
Here are some extra links for things I found helpful along the way.

## Tools

[GitKraken](https://www.gitkraken.com/)
<br/>
An awesome local git manager with a nice interface.

[Postman](https://www.postman.com/)
<br/>
A very handy tool for testing the api routes.

[SQLite Browser](https://sqlitebrowser.org)
<br/>
A useful tool for inspecting the SQLite database through a gui so I never have to learn actual SQL commands.

## Reference pages

[PyEnv & Poetry from Matt Cale](https://dev.to/mattcale/pyenv-poetry-bffs-20k6)
<br/>
For installing different python versions and setting up a virtual environment so vscode doesn't complain.

[Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)
<br/>
For generating Android app icons

[Configuring a PostgreSQL DB with your Dockerized FastAPI App](https://www.jeffastor.com/blog/pairing-a-postgresql-db-with-your-dockerized-fastapi-app/)
<br/>
Tutorial for getting started with FastApi from Jeff Astor

[NPM in Docker](https://www.blackvoid.club/nginx-proxy-manager/)
<br/>
Setting up NPM

[Database Queries with SQLAlchemy](https://hackersandslackers.com/database-queries-sqlalchemy-orm/)
<br/>
Reference page for creating SQL queries with SQLAlchely

[Pass Arguments to Pytest](https://stackoverflow.com/questions/40880259/how-to-pass-arguments-in-pytest-by-command-line)
<br/>
Stackoverflow page for passing arguments into pytest commands

[Marius Hosting](https://mariushosting.com/)
<br/>
For pretty much anything Docker/ Synology related.

[SpaceRex](https://www.youtube.com/@SpaceRexWill)
<br/>
Another great resource for Docker/ local hosting.

[WunderTech](https://www.youtube.com/@WunderTechTutorials)
<br/>
Another great resource for Docker/ local hosting.

[Vandad Nahavandipoor](https://www.youtube.com/c/VandadNP)
<br/>
Longer Flutter tutorials

[FastApi and Uvicorn Logging](https://gist.github.com/liviaerxin/d320e33cbcddcc5df76dd92948e5be3b)
<br/>
Best resource I found for log handling with uvicorn
