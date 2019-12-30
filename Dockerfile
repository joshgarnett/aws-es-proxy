FROM golang:1.13.4-buster as builder

WORKDIR /go/src/github.com/abutaha/aws-es-proxy
COPY . .

RUN mkdir -p $$GOPATH/bin && \
    curl https://glide.sh/get | sh

RUN glide install
RUN go build -o aws-es-proxy

FROM debian:buster
LABEL name="aws-es-proxy" \
      version="latest"

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/
COPY --from=0 /go/src/github.com/abutaha/aws-es-proxy/aws-es-proxy /usr/local/bin/

ENV PORT_NUM 9200
EXPOSE ${PORT_NUM}

ENTRYPOINT ["aws-es-proxy"] 
CMD ["-h"]
