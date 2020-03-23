default: image

all: image

image:
	docker build -f Dockerfile \
	--build-arg FASTJET_VERSION=3.3.3 \
	--build-arg LHAPDF_VERSION=6.2.3 \
	--build-arg PYTHIA_VERSION=8301 \
	--build-arg MG_VERSION=2.7.2 \
	-t matthewfeickert/madgraph5-amc-nlo:latest \
	-t matthewfeickert/madgraph5-amc-nlo:2.7.2
	--compress .
