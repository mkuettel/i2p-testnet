SERVER_EXEC ?= tcpserver
CLIENT_EXEC ?= messenger
SERVER_SRCS := utils.c epoll-server.c
CLIENT_SRCS := client.c proxysocket.c utils.c
SERVER_OBJS := $(SERVER_SRCS:%.c=build/%.o)
CLIENT_OBJS := $(CLIENT_SRCS:%.c=build/%.o)

all: build/$(SERVER_EXEC) build/$(CLIENT_EXEC)

build/$(SERVER_EXEC): $(SERVER_OBJS)
	$(CC) $(SERVER_OBJS) -o $@ $(LDFLAGS)

build/$(CLIENT_EXEC): $(CLIENT_OBJS)
	$(CC) $(CLIENT_OBJS) -o $@ $(LDFLAGS)

build/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

install: build/$(SERVER_EXEC) build/$(CLIENT_EXEC)
	install -m 755 build/$(SERVER_EXEC) /usr/local/bin/tcpserver
	install -m 755 build/$(CLIENT_EXEC) /usr/local/bin/messenger

.PHONY: clean
clean:
	$(RM) build/*

