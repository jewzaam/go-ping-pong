A very simple app that listens on port 8080.
Any request query path is written to standard out and sent as a response to the client with a "Pong" prefix.

# Deploy to minishift
```
minishift start
oc new-project jewzaam
oc project jewzaam
docker build . -t jewzaam/go-ping-pong:latest
docker tag jewzaam/go-ping-pong:latest $(minishift openshift registry)/jewzaam/go-ping-pong:latest
docker push $(minishift openshift registry)/jewzaam/go-ping-pong:latest
```

## Verify
View project by using this URL:
```
minishift console --machine-readable | grep CONSOLE_URL | awk -F= '{print $2 "/console/project/jewzaam/overview"}'
```

# Update deployment
If you change something, simply build, tag, and push.
If you've scaled above default 1 pod you'll see a rolling update.
After you've made your changes:
```
docker build . -t jewzaam/go-ping-pong:latest
docker tag jewzaam/go-ping-pong:latest $(minishift openshift registry)/jewzaam/go-ping-pong:latest
docker push $(minishift openshift registry)/jewzaam/go-ping-pong:latest
```
