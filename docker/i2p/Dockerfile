FROM mkuettel/i2p:latest
#TODO: pin this for reproducability

RUN apk add curl netcat-openbsd python3

ADD ./conf/i2pd.org.conf /home/i2pd/conf/i2pd.org.conf
ADD ./tunnels.conf.d/tcp-in.conf /home/i2pd/tunnels.source.conf.d/tcp-in.conf


