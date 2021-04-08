FROM divax/i2p:latest
#TODO: pin this for reproducability

RUN apk add curl

RUN sed -i 's|^# urls = https.*$|urls = http://10.23.0.1/i2pseeds.su3|g' conf/i2pd.org.conf
RUN grep -F http://10.23.0.1 conf/i2pd.org.conf


