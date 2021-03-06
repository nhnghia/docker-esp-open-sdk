#step 1: build esp-open-sdk from source
FROM ubuntu:16.04 as builder

RUN groupadd -g 1000 docker && useradd docker -u 1000 -g 1000 -s /bin/bash --no-create-home
RUN mkdir /build && chown docker:docker /build

#ENV TERM=xterm\
#    TZ=Europe/Paris\
#    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  make unrar-free autoconf automake libtool gcc g++ gperf \
  flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python-serial \
  sed git unzip bash help2man wget bzip2 libtool-bin

RUN su docker -c " \
    git clone --recursive https://github.com/pfalcon/esp-open-sdk.git /build/esp-open-sdk ; \
    cd /build/esp-open-sdk ; \
    make STANDALONE=n ; \
"


#step 2: copy result to new docker image => reduce the image's size
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y make python python-serial

COPY --from=builder /build/esp-open-sdk/xtensa-lx106-elf /opt/xtensa-lx106-elf

ENV PATH /opt/xtensa-lx106-elf/bin:$PATH

WORKDIR /data
VOLUME ["/data"]
