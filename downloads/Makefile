# Download vasm and vlink source tarballs from upstream

VASMGZ = vasm.tar.gz
VLINKGZ = vlink.tar.gz

VASMURL = http://sun.hasenbraten.de/vasm/release/$(VASMGZ)
VLINKURL = http://sun.hasenbraten.de/vlink/release/$(VLINKGZ)

all: $(VASMGZ) $(VLINKGZ)

$(VASMGZ):
	wget $(VASMURL)

$(VLINKGZ):
	wget $(VLINKURL)
