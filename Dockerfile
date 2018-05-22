FROM golang:1.9

USER nobody

EXPOSE 8080/tcp

RUN mkdir -p /go/src/github.com/jewzaam/go-ping-pong
WORKDIR /go/src/github.com/jewzaam/go-ping-pong

COPY src/main/ping.go /go/src/github.com/jewzaam/go-ping-pong

CMD ["go", "run", "ping.go"]
