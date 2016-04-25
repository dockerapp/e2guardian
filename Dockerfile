FROM debian:jessie
MAINTAINER dockerapp

RUN apt-get -q update &&\
    apt-get -qy --force-yes dist-upgrade &&\
    apt-get install -qy wget unzip automake g++ zlib1g-dev pkg-config libpcre3-dev make

RUN cd /tmp && wget https://github.com/e2guardian/e2guardian/archive/master.zip && \
	unzip master.zip 
#RUN apt-get install -qy libpcre3-dev

RUN cd /tmp/e2guardian-master && \
	./autogen.sh && \
	./configure --sysconfdir=/etc --localstatedir=/var --with-proxygroup=nogroup && \
	make && \
	make install
RUN	sed -i "s/language = 'ukenglish'/language = 'russian-1251'/g" /etc/e2guardian/e2guardian.conf && \
#	sed -i "s/#daemonuser = 'nobody'/daemonuser = 'nobody'/g" /etc/e2guardian/e2guardian.conf && \
#	sed -i "s/#daemongroup = 'nobody'/daemongroup = 'nogroup'/g" /etc/e2guardian/e2guardian.conf && \
	echo '#!/bin/bash' > /run.sh && \
	echo 'sed -i "s/^proxyip =.*/proxyip = `grep proxy /etc/hosts | cut -f1`/g" /etc/e2guardian/e2guardian.conf' >> /run.sh && \
	echo 'exec e2guardian -N' >> /run.sh && chmod +x /run.sh && \
	chown nobody /var/log/e2guardian && \
	rm -rf /tmp/* && rm -rf /var/lib/apt/lists/*

VOLUME /etc/e2guardian/lists
ENTRYPOINT ["/run.sh"]
EXPOSE 8080

