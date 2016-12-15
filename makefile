CC=x86_64-w64-mingw32-gcc

TARGET=get_metrics_native.exe
SOURCES=get_metrics_native.c
OBJECTS=$(SOURCES:.c=.o)
TARGET_LIBS=-lpdh

all: $(TARGET)

c.o:
	$(CC) $<

$(OBJECTS): $(SOURCES)

$(TARGET): $(OBJECTS)
	$(CC) -o $(TARGET) $(OBJECTS) $(TARGET_LIBS)

clean:
	$(RM) $(TARGET) $(OBJECTS)

