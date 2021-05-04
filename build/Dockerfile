FROM alpine:latest

ENV HUGO_VERSION 0.42.1
ENV HUGO_BINARY hugo_${HUGO_VERSION}_linux-64bit
ENV WORKDIR="/docs"

RUN apk --no-cache add git curl asciidoctor

RUN curl -L https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz > hugo.tar.gz
RUN gzip -dc hugo.tar.gz | tar -xof -
RUN mv hugo /usr/local/bin
RUN rm -f hugo.tar.gz
ADD . ${WORKDIR}
WORKDIR ${WORKDIR}
ENTRYPOINT ["/usr/local/bin/hugo"]
