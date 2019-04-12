FROM ruby:2.6.2-alpine3.9

RUN apk add --no-cache ffmpeg mediainfo git build-base
RUN gem install -v '0.1.2' dash_timeline_validator
ENTRYPOINT ["/usr/local/bundle/bin/dash_timeline_validator"]
