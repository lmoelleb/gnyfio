
FROM resin/raspberry-pi-alpine as build

RUN apk update && apk add \
  g++ gcc autoconf libtool git pkgconfig curl \
  automake libtool curl make g++ unzip


ENV GRPC_RELEASE_TAG v1.8.x
RUN git clone -b ${GRPC_RELEASE_TAG} https://github.com/grpc/grpc /var/local/git/grpc && \
		cd /var/local/git/grpc && \
    git submodule update --init && \
    echo "--- installing protobuf ---" && \
    cd /var/local/git/grpc/third_party/protobuf && \
    ./autogen.sh && ./configure --enable-shared && \
    make -j2 && \
    make install && \
    make clean && \
    ldconfig /var/local/lib/ && \
    echo "--- installing grpc ---" && \
    cd /var/local/git/grpc && \
    make -j2  && \
    make install  && \
    make clean  && \
    ldconfig /var/local/lib/ && \
    cd / && \
    rm -rf /var/local/git/grpc

RUN apk add libgcc     
RUN git clone git://git.drogon.net/wiringPi /var/local/wiringPi/
RUN cd /var/local/wiringPi/ && \
    sed -i 's/$sudo//g' build
RUN	cd /var/local/wiringPi/wiringPi && make -j2 static && make install-static


COPY . /usr/local/gnyfio
RUN  cd /usr/local/gnyfio && \
     make -j2

FROM 		resin/raspberry-pi-alpine
MAINTAINER 	Lars Møllebjerg (lars@moellebjerg.com)
COPY 		--from=build /usr/local/gnyfio/bin /usr/local/bin/
COPY 		--from=build /usr/local/lib/ /usr/local/lib/
ENTRYPOINT 	/usr/local/bin/gnyfio
