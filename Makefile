NS = 
VERSION ?= latest
REPO = docker-arm-elk

.PHONY: build push shell run start stop rm release

build:
        docker build -t $(NS)/$(REPO):$(VERSION) .
push:
        docker push $(NS)/$(REPO):$(VERSION)

default: build
