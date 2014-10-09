# Change this to copper or playfields to build other examples
EXE = hello

# Add more .o files here to use multiple sources
OBJS = $(EXE).o

# Amiga cross-assembler/linker
AS = vasm/vasmm68k_mot
LD = vlink/vlink

# Flags to assembler and linker
ASFLAGS = -Fhunk -spaces
LDFLAGS = -bamigahunk -s

all: $(EXE).zip

# Zip executable into hello.zip
# A zip-file can be mounted as a hard drive in UAE
$(EXE).zip: $(EXE)
	zip $@ $<

# Link hello.o into Amiga executable hello
$(EXE): $(OBJS) $(LD)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

# Build the Amiga cross-assembler
$(AS): downloads/vasm.tar.gz
	tar zxvf downloads/vasm.tar.gz
	make CPU=m68k SYNTAX=mot -C vasm

# And the Amiga cross-linker
$(LD): downloads/vlink.tar.gz
	tar zxvf downloads/vlink.tar.gz
	make CPU=m68k SYNTAX=mot -C vlink

# Make in downloads dir downloads vasm.tar.gz and vlink.tar.gz
downloads/vasm.tar.gz:
	make -C downloads

downloads/vlink.tar.gz:
	make -C downloads

.PHONY: clean

clean:
	rm -f $(EXE).zip $(EXE) $(OBJS) *~
