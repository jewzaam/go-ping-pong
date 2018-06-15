FROM golang:1.9

USER nobody

EXPOSE 8080/tcp

# get the golang prometheus client
RUN go get github.com/prometheus/client_golang/prometheus

# setup this application
RUN mkdir -p /go/src/github.com/jewzaam/go-ping-pong
WORKDIR /go/src/github.com/jewzaam/go-ping-pong

# copy local code
COPY src/main/ping.go /go/src/github.com/jewzaam/go-ping-pong

CMD ["go", "run", "ping.go"]
