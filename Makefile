default: image

all: image

image:
	docker build -f Dockerfile \
	--cache-from matthewfeickert/madgraph5-amc-nlo:latest \
	--build-arg MG_VERSION=2.7.2 \
	-t matthewfeickert/madgraph5-amc-nlo:latest \
	-t matthewfeickert/madgraph5-amc-nlo:2.7.2 \
	--compress .
