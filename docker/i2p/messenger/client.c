#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <unistd.h>

#include "utils.h"

#define MAX 80
#define PORT 8080
#define SA struct sockaddr

#define METADATASIZE 256
// 256 kb + metadata to be saved by the server
#define MSGBUFLEN (1024 * 256) + METADATASIZE

#include "proxysocket.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

void logger (int level, const char* message, void* userdata)
{
  const char* lvl;
  if (level > *(int*)userdata)
    return;
  switch (level) {
    case PROXYSOCKET_LOG_ERROR   : lvl = "ERR"; break;
    case PROXYSOCKET_LOG_WARNING : lvl = "WRN"; break;
    case PROXYSOCKET_LOG_INFO    : lvl = "INF"; break;
    case PROXYSOCKET_LOG_DEBUG   : lvl = "DBG"; break;
    default                      : lvl = "???"; break;
  }
  fprintf(stdout, "%s: %s\n", lvl, message);
}

void init_rng() {
  struct timeval seedtime;
  gettimeofday(&seedtime, NULL);
  srand((unsigned int)seedtime.tv_sec ^ (unsigned int)seedtime.tv_usec ^ (unsigned int)getpid());
}

int generate_message(uint8_t* msgbuf, size_t bufsize, unsigned int message_size, unsigned int originator_id, const char * destination) {

    if (bufsize < message_size + METADATASIZE) {
        fprintf(stderr, "Error: can't send messages that big, hardcoded limit to %lu", bufsize);
        exit(1);
    }

    msgbuf[0] = '"';
    for (int i = 1; i < message_size - 1; i++) {
        uint8_t byte = rand() % 256;
        // make sure we don't accidentally send a delimiter
        // delimiters have been chosen to have the last bit not set.
        if (byte == '\0' || byte == '"' || byte == '*' || byte == '$') {
            byte |= 0x01;
        }
        msgbuf[i] = byte;
    }
    msgbuf[message_size - 1] = '*';

    // add timestamp and metadata
    struct timeval tv;
    gettimeofday(&tv, NULL);
    uint64_t sent_at_microseconds = (uint64_t)tv.tv_sec * (uint64_t)1000000 + tv.tv_usec;
    unsigned int metadatasize = snprintf(&msgbuf[message_size], bufsize - message_size, "%u,%s,%u,%ld$", originator_id, destination, message_size, sent_at_microseconds);

    return message_size + metadatasize;
}

void show_help ()
{
  printf(
    "Usage:  messenger [-h] [-S proxy_server] [-P proxy_port] [-d destination] [-p dest_port]\n"
    "Parameters:\n"
    "  -h             \tdisplay command line help\n"
    "  -S proxy_server\tproxy server host name or IP address\n"
    "  -P proxy_port  \tproxy port number\n"
    "  -d destination \the hostname or ip of the server connected through the proxy\n"
    "  -p dest_port   \tdestination port number\n"
    "  -m messagesize \tsize of the message to send in Kb\n"
    "  -o originator  \tan identifier for the originator of the message"
    "  -v             \tverbose mode\n"
    "  -d             \tdebug mode (overrides -v)\n"
    "Description:\n"
    "This client is used to send messages to measure the latency of the i2p network\n"
  );
}

#define GET_PARAM()                     \
  if (argv[i][2])                       \
    param = argv[i] + 2;                \
  else if (i + 1 < argc && argv[i + 1]) \
    param = argv[++i];                  \
  else                                  \
    param = NULL;

int main (int argc, char* argv[])
{
  //get command line parameters
  int i;
  char* param;

  //default is a local i2pd socks5 proxy
  const char* proxyhost = "127.0.0.1";
  uint16_t proxyport = 4445;
  const char* destinationhost = NULL;
  uint16_t destinationport = 2323;
  uint16_t messagesize_kb = 64;
  unsigned int originator_id = 0;
  int verbose = -1;

  for (i = 1; i < argc; i++) {
    //check for command line parameters
    if (argv[i][0] && (argv[i][0] == '/' || argv[i][0] == '-')) {
      switch (argv[i][1]) {
        case 'h' :
        case '?' :
          show_help();
          return 0;
          break;
        case 'S' :
          GET_PARAM()
          if (param)
            proxyhost = param;
          break;
        case 'P' :
          GET_PARAM()
          if (param)
            proxyport = strtol(param, (char**)NULL, 10);
          break;
        case 'd' :
          GET_PARAM()
          if (param)
            destinationhost = param;
          break;
        case 'p' :
          GET_PARAM()
          if (param)
            destinationport = strtol(param, (char**)NULL, 10);
          break;
        case 'm' :
          GET_PARAM()
          if (param)
            messagesize_kb = strtol(param, (char**)NULL, 10);
          break;
        case 'o' :
          GET_PARAM()
          if (param)
            originator_id = strtol(param, (char**)NULL, 10);
          break;
        case 'v' :
          if (verbose < PROXYSOCKET_LOG_INFO)
            verbose = PROXYSOCKET_LOG_INFO;
          break;
        case 'D' :
          verbose = PROXYSOCKET_LOG_DEBUG;
          break;
        default:
          fprintf(stderr, "Invalid command line parameter: %s\n", argv[i]);
          show_help();
          return 1;
      }
    }
  }

  init_rng();

  //make the connection via the specified proxy
  SOCKET sock;
  char* errmsg;
  //prepare for connection
  proxysocket_initialize();
  proxysocketconfig proxy = proxysocketconfig_create_direct(5);
  proxysocketconfig_set_logging(proxy, logger, (int*)&verbose);

  // use i2pd socks5 proxy, resolve names through the proxy
  proxysocketconfig_use_proxy_dns(proxy, 1);
  proxysocketconfig_add_proxy(proxy, PROXYSOCKET_TYPE_SOCKS5, proxyhost, proxyport, NULL, NULL);

  //connect
  errmsg = NULL;
  sock = proxysocket_connect(proxy, destinationhost, destinationport, &errmsg);
  if (sock == INVALID_SOCKET) {
    fprintf(stderr, "%s\n", (errmsg ? errmsg : "Unknown error"));
  } else {
    //send data
    uint8_t msgbuf[MSGBUFLEN] = {};

    unsigned int bytes_to_send = generate_message(msgbuf, MSGBUFLEN, messagesize_kb * 1024, originator_id, destinationhost);

    unsigned int message_position = 0;
    while (message_position < bytes_to_send) {
        int bytes_sent = send(sock, &msgbuf[message_position], bytes_to_send - message_position, 0);
        if (bytes_sent == -1) {
            perror_die("send");
        } else if (bytes_sent == 0) {
            die("connection via proxy closed");
        }

        printf("send %d bytes, pos %u of %u\n", bytes_sent, message_position, bytes_to_send);
        message_position += bytes_sent;
    }
    printf("message of length %u sent from %u to %s\n", messagesize_kb, originator_id, destinationhost);

    proxysocket_disconnect(proxy, sock);
  }
  proxysocketconfig_free(proxy);
  if (errmsg) {
    fprintf(stderr, "Error: %s\n", errmsg);
    free(errmsg);
    return 1;
  }
  return 0;
}
