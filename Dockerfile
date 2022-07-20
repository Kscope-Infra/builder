FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y apt-transport-https bash bc bison bsdmainutils build-essential \
    ca-certificates ccache cgpt clang cron curl flex g++-multilib gcc-multilib git \
    gnupg gperf imagemagick jq kmod lib32ncurses5-dev lib32readline-dev lib32z1-dev \
    liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 \
    libxml2-utils lsof lzop maven openjdk-8-jdk openssh-client perl pngcrush procps \
    python rsync schedtool squashfs-tools tini wget xdelta3 xsltproc yasm zip zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

###
# Repo Setup
###

RUN curl -sLo /usr/local/bin/repo https://commondatastorage.googleapis.com/git-repo-downloads/repo \
    && chmod +x /usr/local/bin/repo

###
# Buildkite Setup
# Taken from https://github.com/buildkite/agent/blob/main/packaging/docker/ubuntu-20.04-linux
###

RUN curl -Lfs -o /sbin/tini https://github.com/krallin/tini/releases/download/v0.19.0/tini \
    && chmod +x /sbin/tini

ENV BUILDKITE_AGENT_CONFIG=/buildkite/buildkite-agent.cfg

RUN mkdir -p /buildkite/builds /buildkite/hooks /buildkite/plugins

RUN curl -sLo /usr/local/bin/buildkite-agent https://download.buildkite.com/agent/stable/latest/buildkite-agent-linux-amd64 \
    && chmod +x /usr/local/bin/buildkite-agent

COPY ./buildkite-agent.cfg /buildkite/buildkite-agent.cfg
COPY ./entrypoint.sh /usr/local/bin/buildkite-agent-entrypoint
RUN chmod +x /usr/local/bin/buildkite-agent-entrypoint

###
# User Setup
###

RUN groupadd -g 1000 buildbot \
    && useradd -u 1000 -g 1000 -d /buildkite buildbot \
    && passwd -d buildbot

RUN chown buildbot:buildbot -R /buildkite

VOLUME /buildkite

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid

COPY ./fixuid.yml /etc/fixuid/config.yml

USER buildbot:buildbot

ENTRYPOINT ["buildkite-agent-entrypoint"]
CMD ["start"]
