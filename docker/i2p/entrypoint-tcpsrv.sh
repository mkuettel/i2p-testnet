# start the message logging tcp server and log to the volume shared with the host
/usr/local/bin/tcpserver /home/i2pd/data/msglog.csv

# now that the TCP server is running use the normal entry point which starts i2pd
/entrypoint.sh
