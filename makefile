CC := g++

BUILDDIR := build
GENDIR := $(BUILDDIR)/gen
TARGETDIR := bin
SRCDIR := src

LIB :=  -lwiringPi -lgrpc++ -lgrpc++_reflection -lprotobuf 
#LIB := -Wl,-Bstatic -lwiringPi -lgrpc++ -lgrpc++_reflection -lprotobuf -Wl,--as-needed
CFLAGS := -g # -Wall
INC := -I include

all: $(TARGETDIR)/gnyfio

$(TARGETDIR)/gnyfio: $(BUILDDIR)/gnyfio.o $(BUILDDIR)/gnyfio.grpc.pb.o $(BUILDDIR)/gnyfio.pb.o
	@mkdir -p $(TARGETDIR)
	@echo " Linking..."
	@echo " $(CC) $^ -o $@ $(LIB)"; $(CC) $^ -o $@ $(LIB)
	
$(BUILDDIR)/%.o: $(SRCDIR)/gnyfio.cpp $(GENDIR)/gnyfio.grpc.pb.h $(GENDIR)/gnyfio.pb.h
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<	
	
$(BUILDDIR)/gnyfio.grpc.pb.o: $(GENDIR)/gnyfio.grpc.pb.cc
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<	

$(BUILDDIR)/gnyfio.pb.o: $(GENDIR)/gnyfio.pb.cc
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<	
	
$(GENDIR)/gnyfio.grpc.pb.h $(GENDIR)/gnyfio.grpc.pb.cc : $(SRCDIR)/proto/gnyfio.proto
	@echo " Generating gRPC source files..."
	@mkdir -p $(GENDIR)
	@protoc --proto_path=$(SRCDIR)/proto --grpc_out=$(GENDIR) --plugin=protoc-gen-grpc=/usr/local/bin/grpc_cpp_plugin $^
	
$(GENDIR)/gnyfio.pb.h $(GENDIR)/gnyfio.pb.cc : $(SRCDIR)/proto/gnyfio.proto
	@echo " Generating Protocol Buffers source files..."
	@mkdir -p $(GENDIR)
	@protoc --proto_path=$(SRCDIR)/proto --cpp_out=$(GENDIR) $^
	
clean:
	@echo " Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGETDIR)"; $(RM) -r $(BUILDDIR) $(TARGET)

 
