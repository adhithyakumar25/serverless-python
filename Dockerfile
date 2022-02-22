FROM python:3.7-slim

ENV APP_HOME /app 
WORKDIR $APP_HOME

COPY . ./app

ENV PYTHONBUFFERED 1
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex \
	&& RUN_DEPS=" \
	libpcre3 \
	mime-support \
	acl \
	" \
	&& seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
	&& apt-get update && apt-get install -y -o --no-install-recommends $RUN_DEPS \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex \
	&& BUILD_DEPS= " \
	build-essential \
	libpcre3-dev \
	libpq-dev \
	acl \
	" \
	&& apt-get update && apt-get install -y -o --no-install-recommends $BUILD_DEPS  \
	\
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS \
	&& rm -rf /var/lib/apt/lists/*


RUN pip install pip pipenv fastapi unicorn --upgrade

RUN pipenv install --skip-lock --system --dev

CMD exec unicorn mail:app --host 0.0.0.0 --port $PORT