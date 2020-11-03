FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https \
      curl \
      ca-certificates \
      bash \
      git \
      perl \
      rsync \
      openssh-client \
      curl \
      jq \
      software-properties-common \
    && rm -rf /var/lib/apt/lists/*

###
# Buildkite Setup
# Taken from https://github.com/buildkite/agent/tree/master/packaging/docker/ubuntu-linux
###

RUN curl -Lfs -o /sbin/tini  https://github.com/krallin/tini/releases/download/v0.18.0/tini \
    && chmod +x /sbin/tini

ENV BUILDKITE_AGENT_CONFIG=/buildkite/buildkite-agent.cfg

RUN mkdir -p /buildkite/builds /buildkite/hooks /buildkite/plugins

RUN curl -sLo /usr/local/bin/buildkite-agent https://download.buildkite.com/agent/stable/latest/buildkite-agent-linux-amd64

COPY ./buildkite-agent.cfg /buildkite/buildkite-agent.cfg
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /buildkite
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]

RUN apt-add-repository ppa:deadsnakes/ppa

###
# Android Start
###

COPY ./hooks /buildkite/hooks

# Install Repo
RUN curl -sLo /usr/local/bin/repo https://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod +x /usr/local/bin/repo

# Install android dependencies
RUN apt update && apt -y upgrade && apt -y install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline6-dev lib32z1-dev libbz2-dev liblz4-tool libncurses5-dev libreadline-dev libsdl1.2-dev libsqlite3-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils llvm lzop openjdk-8-jdk pngcrush rsync schedtool squashfs-tools wget xsltproc zip zlib1g-dev python python-pip python3.6

RUN git config --global user.name "LineageOS Android Builder"
RUN git config --global user.email "nobody@localhost"

COPY lineage-init.sh /usr/local/bin/lineage-init
RUN chmod +x /usr/local/bin/lineage-init && /usr/local/bin/lineage-init

VOLUME /lineage

