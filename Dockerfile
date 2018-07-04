FROM ruby:2.5.1

LABEL maintainer="Michael Senn <michael@morrolan.ch>"

EXPOSE 8080

# Tiny Init. (Reap zombies, forward signals)
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Create non-privileged user
RUN groupadd -r gorge && useradd -r -g gorge gorge

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
# Throw error if Gemfile was modified after Gemfile.lock
RUN bundle config --global frozen 1
# Installing gems before copying source allows caching of gem installation.
COPY Gemfile Gemfile.lock /usr/src/app/
ARG BUNDLE_EXCLUDE_GROUPS="development test"
RUN bundle install --without $BUNDLE_EXCLUDE_GROUPS
COPY . /usr/src/app

RUN chmod +x "./docker-entrypoint.sh"

USER gorge
ENTRYPOINT ["/tini", "--", "./docker-entrypoint.sh"]
