#!/bin/sh

# start the message logging tcp server and log to the volume shared with the host
su i2pd -c 'mkdir /home/i2pd/data/messagelogs'
su i2pd -c '/usr/local/bin/tcpserver /home/i2pd/data/messagelogs/msglog.csv' 2323 &

# now that the TCP server is running use the normal entry point which starts i2pd
exec /entrypoint.sh
