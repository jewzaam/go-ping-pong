A very simple app that listens on port 8080.
Any request query path is logged and sent as a response to the client with a "Pong" prefix.

# Using on minishift

## Prereqs
Required for all other sections, you need minishift running, the docker-env setup, and need to be logged in.
First, [Install Minishift](https://docs.openshift.org/latest/minishift/getting-started/installing.html)
Then...
```
minishift start
# setup docker env to use the minishift docker
eval $(minishift docker-env)
# setup to use minishift's oc binary
eval $(minishift oc-env)
# log into the registry as user 'developer'
docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)
```

## New project
For the initial setup, create the project.  First deployment is the same as pushing an update.
```
# create the project
oc new-project jewzaam
# switch to use the new project
oc project jewzaam
```

# Deploy
First deployment also requires creation of the app after this step.
If you've scaled above default 1 pod you'll see a rolling update.
```
# build the image
docker build . -t jewzaam/go-ping-pong:latest
# tag it
docker tag jewzaam/go-ping-pong:latest $(minishift openshift registry)/jewzaam/go-ping-pong:latest
# push it
docker push $(minishift openshift registry)/jewzaam/go-ping-pong:latest
```

## New App
Deploy the app, scale to 2 replicas, and expose on port 8080:
```
# create the app from the pushed image stream
oc new-app jewzaam/go-ping-pong
# scale to 2 pods, so subsequent updates are rolling
oc scale --replicas=2 dc go-ping-pong
# expose the service on port 8080 (creates a route)
oc expose service go-ping-pong --port=8080
```

## Verify
View project by using this URL:
```
minishift console --machine-readable | grep CONSOLE_URL | awk -F= '{print $2 "/console/project/jewzaam/overview"}'
```
