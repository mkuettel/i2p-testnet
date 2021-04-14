FROM mkuettel/i2p:latest
#TODO: pin this for reproducability

RUN apk add curl netcat-openbsd

RUN sed -i 's|^# urls = https.*$|urls = http://10.23.0.1:8443/|g' conf/i2pd.org.conf
RUN sed -i 's|^verify = true.*$|verify = false|g' conf/i2pd.org.conf
RUN grep -F http://10.23.0.1 conf/i2pd.org.conf


