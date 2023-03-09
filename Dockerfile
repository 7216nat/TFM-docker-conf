FROM ubuntu:22.04
RUN apt-get update && apt-get -y install gawk wget git \
    diffstat unzip texinfo gcc-multilib build-essential \
    chrpath socat cpio python-is-python3 sudo python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    libsdl1.2-dev xterm tar locales curl nano file vim liblz4-tool zstd

# Set locales:
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# User settings. Should be passed using --build-arg when building the image. Otherwise, you can expect accesss errors.
ARG USER_NAME=yob
ARG HOST_UID=1000
ARG HOST_GID=1000
ARG GIT_USER_NAME="dummyName"
ARG GIT_EMAIL="dummy@email.com"

# Add the user to the image's linux:
RUN groupadd -g $HOST_GID $USER_NAME && \
    useradd -g $HOST_GID -m -s /bin/bash -u $HOST_UID $USER_NAME
USER $USER_NAME
ENV USER_FOLDER /home/$USER_NAME

# Setup folders:
RUN mkdir -p $USER_FOLDER/bin
RUN mkdir -p $USER_FOLDER/AGL

# Download the agl's "repo" tool:
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > $USER_FOLDER/bin/repo
RUN chmod a+x $USER_FOLDER/bin/repo
ENV PATH="$USER_FOLDER/bin:${PATH}"

# Configures image's linux git config:
RUN git config --global user.email "$GIT_USER_NAME"
RUN git config --global user.name "$GIT_EMAIL"

COPY --chown=$USER_NAME:$USER_NAME build.sh $USER_FOLDER/AGL/
RUN chmod a+x $USER_FOLDER/AGL/build.sh

WORKDIR $USER_FOLDER/AGL
