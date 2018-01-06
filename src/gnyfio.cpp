#include <iostream>
#include <grpc/grpc.h>
#include <grpc++/server.h>
#include <grpc++/server_builder.h>
#include <grpc++/server_context.h>
#include <grpc++/security/server_credentials.h>

#include "../build/gen/gnyfio.grpc.pb.h"
// If wiringPi is included before the grpc includes, the compile will fail.
// I do not want to know why at this moment... moving on :)
#include <wiringPi.h>

using namespace std;

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;


class GnyfioServiceImplementation final : public GnyfioService::Service
{
	Status SetPinMode(ServerContext* context, const SetPinModeRequest* request, SetPinModeResponse* response) override {
		struct timespec gettime_now;

		clock_gettime(CLOCK_REALTIME, &gettime_now);
		response->set_timestamp_ns(gettime_now.tv_nsec);
		return Status::OK;
	}
	
};

std::string getCmdOption(int argc, char **argv, const std::string& option, const std::string &defaultValue)
{
	std::string cmd;
	std::string pattern = "-" + option + "=";
	for (int i = 0; i < argc; i++)
	{
		std::string arg = argv[i];
		if (0 == arg.find(pattern))
		{
			cmd = arg.substr(pattern.length());
			return cmd;
		}
	} 
	std::string envName = "GNYFIO_" + option;
	
	std::transform(envName.begin(), envName.end(),envName.begin(), ::toupper);
	
	if (const char* env = std::getenv(envName.c_str()))
	{
		return env;
	}
	
	return defaultValue;
}

int main(int argc, char **argv)
{
	wiringPiSetup () ;
	// TODO: Allow specifying port and IP address binding through command line and environment variable.
	std::string server_address = getCmdOption(argc, argv, "address", "0.0.0.0:50051");
	
	GnyfioServiceImplementation service;
	
	ServerBuilder builder;
	
	// TODO: Support credentials through command line and environment variable.
	builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());

	builder.RegisterService(&service);

	std::unique_ptr<Server> server(builder.BuildAndStart());

	std::cout << "Gnyfio server listening on " << server_address << std::endl;

	server->Wait();
	
}
