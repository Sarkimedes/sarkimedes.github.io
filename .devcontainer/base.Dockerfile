ARG VARIANT=3.4-bookworm
FROM mcr.microsoft.com/vscode/devcontainers/ruby:${VARIANT}
COPY library-scripts/meta.env /usr/local/etc/vscode-dev-containers

# ENV Variables required by Jekyll
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    TZ=Etc/UTC \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US

# Install bundler, latest jekyll, and github-pages for older jekyll
RUN gem update --system

# https://github.com/ntkme/sass-embedded-host-ruby/issues/130
RUN gem install sass-embedded -v 1.62.1
RUN gem install jekyll-sass-converter -v 3.0.0


# Install bundler, latest jekyll, and github-pages for older jekyll
RUN gem install bundler jekyll github-pages


# The gem installs above run as root and create/populate subdirectories of
# GEM_HOME (/usr/local/bundle) with root-only permissions, even though the
# Ruby base image sets GEM_HOME itself to 1777. This leaves the non-root
# "vscode" user unable to run `bundle install` (Bundler::PermissionError).
# Align /usr/local/bundle with the same group-writable + setgid pattern
# already used for /usr/local/rubies so "vscode" (a member of the "ruby"
# group) can write there too.
RUN chgrp -R ruby "/usr/local/bundle" \
    && chmod -R g+rwX "/usr/local/bundle" \
    && find "/usr/local/bundle" -type d | xargs -n 1 chmod g+s

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
