FROM alpine:latest
# webproc release settings
ENV WEBPROC_VERSION 0.4.0
ARG BUILDARCH
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v${WEBPROC_VERSION}/webproc_${WEBPROC_VERSION}_linux_${BUILDARCH}.gz
# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps
#configure dnsmasq
RUN echo $'# Use CloudFlare NS Servers\n\
server=1.0.0.1\n\
server=1.1.1.1\n# Serve all .company queries using a specific nameserver\n\
server=/company/10.0.0.1\n# Define Hosts DNS Records\n\
address=/myhost.company/10.0.0.2\n' > /etc/dnsmasq.conf

# https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
ENTRYPOINT ["webproc", "-c", "/etc/dnsmasq.conf", "-c", "/etc/hosts", "--", "dnsmasq", "--no-daemon", "--log-queries", "--no-resolv", "--strict-order"]