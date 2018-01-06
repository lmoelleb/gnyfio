# gnyfio
The goal of Gnyfio is to expose the GPIO pins of a Raspberry Pi in
a way that is optimized for a microservice architecture where one or
more microservices needs access to control pins.

## Design goals:
1. Light weight
1. Simple. Controls the GPIO (including SPI etc) but offers no advanced 
functionality like software debouncing buttons etc.
1. Support for exposing the GPIO pins over the network.
1. Support for interrupts.

## Design choices:
1. The implementation will be based on Wiring Pi as this provides easy
access to all functionality required.
1. gRPC will be used as the communication protocol.
  * REST was considered as well, but it is slower and does not support  
callbacks in case of interrupts. Workarounds are available (long polling,
websockets) but this adds complexity.
  * MQTT adds another layer and limits performance. Translation of GPIO
requests to and from MQTT is better performed by a separate microservice.
1. Implementation will be done in C++
  * The functionality is very limited and does not benefit hugely from
higher level languages.
  * Allows native linking with the Wiring Pi library.
  * Keeps the docker container light weight as it does not need to contain
a high level runtime.
    
## Dependencies
The dependencies must be installed before building.

* [WiringPi](http://wiringpi.com/)
  * If building on a Raspberry Pi you probably have this installed already.
* [gRPC](https://grpc.io/)
  * After following the instructions to install from source also run
`make install` in the third_party/protobuf folder.

## Build
1. Run "make" in the repository root folder.

