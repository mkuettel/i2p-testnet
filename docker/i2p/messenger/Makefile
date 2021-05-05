SERVER_EXEC ?= tcpserver
SRCS := proxysocket.c utils.c epoll-server.c
OBJS := $(SRCS:%.c=build/%.o)

build/$(SERVER_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

build/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

install: build/$(SERVER_EXEC)
	install -m 644 build/$(SERVER_EXEC) /usr/local/bin/tcpserver

.PHONY: clean
clean:
	$(RM) build/*

