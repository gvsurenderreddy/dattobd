BINARY_NAME = update-img
INSTALLDIR = $(PREFIX)/bin
SOURCES = update-img.c

.PHONY: all install clean

all:
	$(CC) $(CCFLAGS) -o $(BINARY_NAME) $(SOURCES) $(BASE_DIR)/lib/libdattobd.a

install: all
	mkdir -p $(INSTALLDIR)
	install $(BINARY_NAME) $(INSTALLDIR)

clean:
	rm -f $(BINARY_NAME)
