A very simple app that listens on port 8080.
Any request query path is logged and sent as a response to the client with a "Pong" prefix.

# Using on minishift

## Prereqs
Required for all other sections, you need minishift running, the docker-env setup, and need to be logged in.
```
minishift start
eval $(minishift docker-env)
docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
```

## New project
For the initial setup, create the project.  First deployment is the same as pushing an update.
```
oc new-project jewzaam
oc project jewzaam
```

# Deploy
First deployment also requires creation of the app after this step.
If you've scaled above default 1 pod you'll see a rolling update.
```
docker build . -t jewzaam/go-ping-pong:latest
docker tag jewzaam/go-ping-pong:latest $(minishift openshift registry)/jewzaam/go-ping-pong:latest
docker push $(minishift openshift registry)/jewzaam/go-ping-pong:latest
```

## New App
Deploy the app, scale to 2 replicas, and expose on port 8080:
```
oc new-app jewzaam/go-ping-pong
oc scale --replicas=2 dc go-ping-pong
oc expose service go-ping-pong --port=8080
```

## Verify
View project by using this URL:
```
minishift console --machine-readable | grep CONSOLE_URL | awk -F= '{print $2 "/console/project/jewzaam/overview"}'
```
