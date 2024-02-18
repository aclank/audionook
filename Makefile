.PHONY: style check-style start install develop test load-test
style:
	# apply opinionated styles
	@black src
	@isort src

	# tests are production code too!
	@black tests
	@isort tests

check-style:
	@black src --check
	@flake8 stc --count --show-source --statistics --ignore=E203,W503

# I assume that you will need to change the container names <aclank/audionook>
# to something else if trying to push this back up to docker hub so it won't
# clash with mine. I'm not the most familiar with docker commands though..

docker-build:
	@docker build -f docker/Dockerfile-prod -t aclank/audionook .

docker-build-dev:
	@docker build -f docker/Dockerfile-dev -t aclank/audionook_dev .

docker-push:
	@docker push aclank/aclank/audionook

docker-push-dev:
	@docker push aclank/aclank/audionook_dev

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

docker-stop:
	@docker stop docker_audionook_dev

docker-logs:
	@docker logs docker_audionook_dev

tarball-dev:
	@rm -f ./docker/audionook_dev.tarball
	@tar -cvf docker/audionook_dev.tar --transform 'flags=r;s|docker/Dockerfile-dev|Dockerfile|' docker/Dockerfile-dev requirements

tarball:
	@rm -f ./docker/audionook.tarball
	@tar -cvf docker/audionook.tar \
	--transform 'flags=r;s|docker/Dockerfile|Dockerfile|' docker/Dockerfile \
	requirements \
	src \
	web/html \
	web/nginx \
	web/flutter/build/web \
	bin/run.sh \
	bin/supervisord.conf

# Leaving these here as an example of docker-compose commands but I'm not using 
# postgres for the db anymore so they dont work as-is.
# docker-compose-postgres-dev:
# 	@docker-compose -f docker/docker-compose-postgres-dev.yml up --build

# docker-stop-compose:
# 	@docker-compose -f docker/docker-compose-postgres-dev.yml down

num-lines:
	@python3 ./tests/num_lines.py

# I haven't spent much time on tests cause I'm a bad dev so these probably dont work
test:
	@pytest -v -r=sw ./tests/users/login_and_get_users.py

load-test:
	# run load tests
	@pytest ./tests/load
