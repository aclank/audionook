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
| WIKI_USER_AGENT | An optional http header for getting some metadata about authors. Syntax for the Wiki User Agent is like this <br/> (The app is built with pip wikipedia-api==0.6.0 so that part needs to stay the same): <br/> \<apiname>/\<apiversion> (\<your-host-domain>; \<your-email>) wikipedia-api/0.6.0 <br/> scrivapi/0.01 (example.domain.com; <span>your-email@gmail</span>.com) wikipedia-api/0.6.0 | 

Once the docker container is running you can checkout the website at `http://localhost:public-port`

Create an admin account and generate the library based off the books you supply. Start listening and enjoy!

## Library File Structure
At the moment this app requires a quite strict folder structure for the audio files. At the top level are `Author Name` folders and inside there should be `book-_-num-_-Title` folder (num is optional)

You can have any number of `series-_-num-_-Title` folders (again num is optional) which contain the book folders. 

Each book folder needs a `version-_-type-_-v##` that holds the actual audio files. 

You can supply an `author-_-Name.jpg` and `cover-_-Title.jpg` in the respective author and book folders. Otherwise Audionook will try to download an image off of google (or perhaps just fallback on a placeholder. Placeholder for now)

Here is an example folder structure
```
Brandon Sanderson
  - series-_-Mistborn
    - series-_-01-_-Original Trilogy (Era One)
      - book-_-01-_-The Final Empire
        - version-_-mp3_v01
          - audio_files.mp3
        - version-_-Graphic Audio_v01
          - audio_files.mp3
        - cover-_-The Final Empire.jpg
      - book-_-02-_-The Well of Ascension
        - version-_-mp3_v01
          - audio_files.mp3
        - cover-_-The Well of Ascension.jpg
    - series-_-02-_-Wax and Wayne Series (Era Two)
      - book-_-04 - The Alloy of Law
        - version-_-mp3_v01
          - audio_files.mp3
        - cover-_-The Alloy of Law.jpg
      - book-_-05 - Shadows of Self
        - version-_-m4b_v01
          - audio_files.m4b
        - cover-_-Shadows of Self.jpg
  - book-_-Warbreaker
    - version-_-mp3_v01
      - audio_files.mp3
    - cover-_-Warbreaker
  - author-_-Brandon Sanderson.jpg
```

This would have 6 unique versions for a total of 5 books. Some of the books are part of a series (Mistborn Era One) which is itself part of a series (Mistborn) while some books are standalone (Warbreaker)

The app requires this folder structure so that the books can be organized by author and series which is a way I strongly prefer to browse my library over other audiobook managers I've tried which put books into a long list and that's it. 

<h1 align="center">Development</h1>

From here down the README needs improvement
## Generate docker images and deploy compose files on portainer
Download the repo

'make tarball-dev' (or prod)

In Portainer -> Images -> Build a new image -> Upload

Set the container name (your/container_name)

Select file (audionook_dev.tar was generated in step 1)

Build the image (sometimes I have to build the prod image twice because it'll fail with: Unexpected token < blabla)

In Portainer -> Stacks -> Add stack -> copy/ paste docker-compose-dev.yml

\+ Add an environment variable * 3 (SECRET_KEY, WIKI_USER_AGENT, ENVIRON_LOGLEVEL)

Update the stack

## Alembic Database Migrations
I am terrible at database migrations. Here are some notes I made at some point that might help.

https://www.jeffastor.com/blog/pairing-a-postgresql-db-with-your-dockerized-fastapi-app/

sudo docker exec -it \<container> bash

alembic revision -m "create_main_tables"

this will make a file in ./src/db/migrations/versions/####_"whatever_was_in_quotes".py for creating the main tables.

Add stuff in there

alembic upgrade head<br/>
alembic downgrade head?

## Public Access
Port foward your `<public-port>` on your router. If you own a domain name you could setup a reverse proxy in the same or another portainer stack and give your server a proper url/ ssl. Or any other way of doing that. Otherwise you can access the site at `http://<your-public-ip>:<public-port>`
