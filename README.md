A very simple app that listens on port 8080.
Any request query path is logged and sent as a response to the client with a "Pong" prefix.

# Local Test
Run without using docker or openshift:

```
go get github.com/prometheus/client_golang
go run src/main/ping.go
```

Any endpoint other than `/metrics` will return a pong:

```
$ curl http://localhost:8080/it-works
Pong: "/it-works"
```

The `/metrics` endpoint will return Prometheus style metrics.

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
oc login -u developer
docker login -u $(oc whoami) -p $(oc whoami -t) $(minishift openshift registry)
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
NAMESPACE=jewzaam
# build the image
docker build . -t $NAMESPACE/go-ping-pong:latest
# tag it
docker tag $NAMESPACE/go-ping-pong:latest $(minishift openshift registry)/$NAMESPACE/go-ping-pong:latest
# push it
docker push $(minishift openshift registry)/$NAMESPACE/go-ping-pong:latest
```

## New App
Only needs to be done for initial deployment.  Subsequent pushes will automatically be deployed.

Deploy the new app, scale to 2 replicas, and expose on port 8080:
```
NAMESPACE=jewzaam
# create the app from the pushed image stream
oc new-app $NAMESPACE/go-ping-pong
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

# Prometheus Integration
It's assumed you have Prometheus installed.  You can review [OpenShift and Prometheus](https://www.robustperception.io/openshift-and-prometheus/) for some help getting started.

NOTE for this setup to work this project must be in the same namespace as Prometheus.

Once this project is installed you can add 'go-ping-pong' to the prometheus config.

View config map:  `oc describe configMap $(oc get configMap | grep -v NAME | awk '{print $1}')`
Edit config map:  `oc edit configMap $(oc get configMap | grep -v NAME | awk '{print $1}')`

A sample config is provided in `prometheus.yml`.
