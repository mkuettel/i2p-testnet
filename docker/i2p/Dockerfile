FROM mkuettel/i2p:latest
#TODO: pin this for reproducability

ADD messenger/ /tmp/messenger-build

RUN apk --no-cache --virtual build-dependendencies add \
    musl-dev \
    make \
    gcc \
  && cd /tmp/messenger-build \
  && rm -rf build && mkdir build \
  && make \
  && make install \
  && apk --no-cache --purge del build-dependendencies

RUN apk add curl netcat-openbsd w3m


ADD ./conf/i2pd.org.conf /home/i2pd/conf/i2pd.org.conf
ADD ./tunnels.conf.d/tcp-in.conf /home/i2pd/tunnels.source.conf.d/tcp-in.conf
ADD ./entrypoint-tcpsrv.sh

ENTRYPOINT ["/entrypoint-tcpsrv.sh"]
