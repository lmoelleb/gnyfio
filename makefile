# based on:
# https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/

CC := g++
SRCDIR := src
BUILDDIR := build
TARGETDIR := build
TARGET := bin/gnyfio
PROTODIR := $(SRCDIR)/proto
PROTOBASENAME := gnyfio
PROTOFILE := $(PROTODIR)/$(PROTOBASENAME).proto
GENERATEDDIR := build/gen
PROTOGENERATEDCCFILE := $(GENERATEDDIR)/$(PROTOBASENAME).pb.cc
GRPCGENERATEDCCFILE := $(GENERATEDDIR)/$(PROTOBASENAME).grpc.pb.cc 
SRCEXT := cpp
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o)) $(GENERATEDDIR)/$(PROTOBASENAME).o $(GENERATEDDIR)/$(PROTOBASENAME).grpc.o
CFLAGS := -g # -Wall
LIB := -lwiringPi -lgrpc++ -lgrpc++_reflection -ldl -lprotobuf
INC := -I include

$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	@echo " Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $^ -o $(TARGET) $(LIB)

# TODO: Refector so there is no copy-paste to get the generated code compiled.
$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

$(GENERATEDDIR)/$(PROTOBASENAME).o: $(PROTOGENERATEDCCFILE)
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<
	
$(GENERATEDDIR)/$(PROTOBASENAME).grpc.o: $(GRPCGENERATEDCCFILE)
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<	

	
$(PROTOGENERATEDCCFILE): $(PROTOFILE)
	@echo " Generating protobuf source files..."
	@mkdir -p $(GENERATEDDIR)
	@protoc --proto_path=$(PROTODIR) --cpp_out=$(GENERATEDDIR) $(PROTOFILE)

$(GRPCGENERATEDCCFILE): $(PROTOFILE)
	@echo " Generating gRPC source files..."
	@mkdir -p $(GENERATEDDIR)
	@protoc --proto_path=$(PROTODIR) --grpc_out=$(GENERATEDDIR) --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin $(PROTOFILE)
	
clean:
	@echo " Cleaning...$(GRPCGENERATEDCCFILE)"; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGET)"; $(RM) -r $(BUILDDIR) $(TARGET)

# Updates GRPC source files only
grpc: $(PROTOGENERATEDCCFILE)

.PHONY: clean grpc
