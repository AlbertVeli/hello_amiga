# Add more .o files here to use multiple sources
OBJS = hello.o

AS = vasm/vasmm68k_mot
LD = vlink/vlink

all: hello.zip

# Template to build .o files from .s files
%.o: %.s $(AS)
	$(AS) -Fhunk -spaces -o $@ $<

# Zip executable into hello.zip
# A zip-file can be mounted as a hard drive in UAE
hello.zip: hello
	zip $@ $<

# Link hello.o into Amiga executable hello
hello: $(OBJS) $(LD)
	$(LD) -bamigahunk -o $@ -s $(OBJS)

# Build the Amiga assembler
$(AS): downloads/vasm.tar.gz
	tar zxvf downloads/vasm.tar.gz
	make CPU=m68k SYNTAX=mot -C vasm

# And the Amiga linker
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
	rm -f hello.zip hello $(OBJS) *~
