
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

# Using on minikube

## Prereqs

```
minikube start
```

## Build and Push

```
NAMESPACE=jewzaam
# build the image
docker build . -t $(minikube ip):5000/$NAMESPACE/go-ping-pong:latest
# push it
docker push $(minikube ip):5000/$NAMESPACE/go-ping-pong:latest
```

## Deploy

```
oc create -f oc/deployment/01-deployment.yml
oc create -f oc/deployment/02-service.yml
```

## Test

```
oc port-forward $(oc get pods -l=app=go-ping-pong -o name) 8080:8080 &
curl localhost:8080/hello
```

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

## Build and Push

```
NAMESPACE=jewzaam
# build the image
docker build . -t $NAMESPACE/go-ping-pong:latest
# tag it
docker tag $NAMESPACE/go-ping-pong:latest $(minishift openshift registry)/$NAMESPACE/go-ping-pong:latest
# push it
docker push $(minishift openshift registry)/$NAMESPACE/go-ping-pong:latest
```

# Deploy
If you are working locally and want to push changes without having to push to master on github use the "Deploy: Manual" option.  For triggered rebuilds use "Deploy: BuildConfig".  Verify steps are the same for both.


## New App (minishift)
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

## Deploy: BuildConfig (minishift)

Create the build config:

```
oc create -f oc/build/buildconfig.yml
```

## Deploy: Deployment (minishift)

Deploy from remote image on quay.io.  Creates a deployment, service, and route.

```
oc apply -f oc/deployment/
```

## Verify
View project by using this URL:
```
minishift console --machine-readable | grep CONSOLE_URL | awk -F= '{print $2 "/console/project/jewzaam/overview"}'
```

# Prometheus Integration (broken)
It's assumed you have Prometheus installed.  You can review [OpenShift and Prometheus](https://www.robustperception.io/openshift-and-prometheus/) for some help getting started.

Once this project is installed you can add 'go-ping-pong' to the prometheus config.  Note this connects to the service (internal), not the route (external), and therefore uses the internal port (8080) and service name (go-ping-pong.jewzaam.svc).

View config map:  `oc describe configMap $(oc get configMap | grep -v NAME | awk '{print $1}')`

Edit config map:  `oc edit configMap $(oc get configMap | grep -v NAME | awk '{print $1}')`

A sample config is provided in `prometheus.yml`.

Additional network configuration may be necessary if you are monitoring an app outside of the prometheus project and are not using the `ovs-subnet` plugin.  See the [Managing Networking](https://docs.openshift.com/container-platform/3.5/admin_guide/managing_networking.html) documentation on how to [join project networks](https://docs.openshift.com/container-platform/3.5/admin_guide/managing_networking.html#joining-project-networks).
