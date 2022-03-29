FROM alpine:3.15.3

EXPOSE 1313

RUN apk update && apk add py-pygments bash curl git && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["bash", "-c"]

RUN mkdir /usr/local/hugo

ENV HUGO_VERSION 0.69.0
ENV HUGO_BINARY hugo_${HUGO_VERSION}_linux-64bit
RUN curl -L -o- https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz | tar xzf - -C /usr/local/hugo/ \
	&& ln -s /usr/local/hugo/hugo /usr/local/bin/hugo
