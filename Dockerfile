# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.3.0
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /myapp

ENV RAILS_ENV="development" \
  BUNDLE_PATH="/usr/local/bundle"

# Throw-away build stage to reduce size of final image
FROM base as build

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev git libvips pkg-config

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y curl default-mysql-client libvips && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /myapp /myapp

RUN useradd rails --create-home --shell /bin/bash && \
  chown -R rails:rails db log storage tmp
USER rails:rails

ENTRYPOINT ["/myapp/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
