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
GRPCGENERATEDCCFILE := $(GENERATEDDIR)/$(PROTOBASENAME).pb.cc
 
SRCEXT := cpp
SOURCES := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o)) $(GENERATEDDIR)/$(PROTOBASENAME).o
CFLAGS := -g # -Wall
LIB := -lwiringPi -lgrpc++ -lgrpc++_reflection -ldl -lprotobuf
INC := -I include

$(TARGET): $(OBJECTS)
	@mkdir -p $(@D)
	@echo " Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $^ -o $(TARGET) $(LIB)

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<


$(GENERATEDDIR)/$(PROTOBASENAME).o: $(GRPCGENERATEDCCFILE)
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

	
$(GRPCGENERATEDCCFILE): $(PROTOFILE)
	@echo " Compiling proto file..."
	@mkdir -p $(GENERATEDDIR)
	@protoc --proto_path=$(PROTODIR) --cpp_out=$(GENERATEDDIR) --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin $(PROTOFILE)
	
clean:
	@echo " Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGET)"; $(RM) -r $(BUILDDIR) $(TARGET)
	
grpc: $(GRPCGENERATEDCCFILE)

.PHONY: clean
