
FROM resin/raspberry-pi-alpine as devenv


RUN apk update && apk add \
  g++ gcc autoconf libtool git pkgconfig curl \
  automake libtool curl make g++ unzip 

# install protobuf first, then grpc
ENV GRPC_RELEASE_TAG v1.8.x
RUN git clone -b ${GRPC_RELEASE_TAG} https://github.com/grpc/grpc /var/local/git/grpc && \
		cd /var/local/git/grpc && \
    git submodule update --init && \
    echo "--- installing protobuf ---" && \
    cd third_party/protobuf && \
    ./autogen.sh && ./configure --enable-shared && \
    make -j$(nproc) && make -j$(nproc) check && make install && make clean && ldconfig && \
    echo "--- installing grpc ---" && \
    cd /var/local/git/grpc && \
    make -j$(nproc) && make install && make clean && ldconfig

# Install wiringPi 
# First add the head json file of wiringPi, this will force our cache to be invalidated 
# if there is a new checkin to WiringPi
ADD https://git,drogon.net/?p=wiringPi;a=shortlog wiringPiLog.html
RUN /usr/libexec/git-core/git clone git://git.drogon.net/wiringPi /var/local/git/wiringPi
RUN cd /var/local/git/wiringPi && ./build

# TODO: Copy project and start build

FROM resin/raspberry-pi-alpine
MAINTAINER Lars Møllebjerg (lars@moellebjerg.com)

# TODO: Copy result over

#COPY bin/gnyfio .

#ENTRYPOINT ./gnyfio
