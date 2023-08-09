FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install -y build-essential git curl gcc binutils python3 cmake
RUN useradd --system builder
USER builder:builder
WORKDIR /home/builder
RUN git clone -b v1.10.2 https://github.com/ninja-build/ninja.git
RUN mkdir /home/builder/ninja-build
RUN cmake -S /home/builder/ninja -B /home/builder/ninja-build
WORKDIR /home/builder/ninja-build
RUN make -j 20

