
FROM resin/raspberry-pi-alpine as devenv


RUN apk update && apk add \
  g++ gcc autoconf libtool git pkgconfig curl \
  automake libtool curl make g++ unzip 

# install protobuf first, then grpc
ENV GRPC_RELEASE_TAG v1.8.x
RUN git clone -b ${GRPC_RELEASE_TAG} https://github.com/grpc/grpc /var/local/git/grpc && \
		cd /var/local/git/grpc && \
    git submodule update --init
RUN echo "--- installing protobuf ---" && \
    cd /var/local/git/grpc/third_party/protobuf && \
    ./autogen.sh && ./configure --enable-shared
RUN cd /var/local/git/grpc/third_party/protobuf && make -j4
RUN cd /var/local/git/grpc/third_party/protobuf && make install
RUN cd /var/local/git/grpc/third_party/protobuf && make clean
RUN cd /var/local/git/grpc/third_party/protobuf && ldconfig /
RUN echo "--- installing grpc ---" && \
    cd /var/local/git/grpc && \
    make -j2 
RUN cd /var/local/git/grpc && make install
RUN cd /var/local/git/grpc && make clean
RUN cd /var/local/git/grpc && ldconfig /

RUN apk add wiringpi
FROM resin/raspberry-pi-alpine
MAINTAINER Lars Møllebjerg (lars@moellebjerg.com)

# TODO: Copy result over

#COPY bin/gnyfio .

#ENTRYPOINT ./gnyfio
