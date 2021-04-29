SERVER_EXEC ?= tcpserver
SRCS := proxysocket.c utils.c epoll-server.c
OBJS := $(SRCS:%.c=build/%.o)

build/$(SERVER_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

build/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	$(RM) build/*

