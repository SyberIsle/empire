.PHONY: build test bootstrap

REPO = remind101/empire
TYPE ?= patch
ARTIFACTS ?= build

cmds: build/empire build/emp

clean:
	rm -rf build/*

build/empire:
	go build -o build/empire ./cmd/empire

build/emp:
	go build -o build/emp ./cmd/emp

bootstrap: cmds
	createdb empire || true
	./build/empire migrate

build: Dockerfile
	docker build -t ${REPO} .

push: build
	docker tag remind101/empire:latest outsideopen/empire:master
	docker push outsideopen/empire:master

test: build/emp
	go test -race $(shell go list ./... | grep -v /vendor/)
	./tests/deps

vet:
	go vet $(shell go list ./... | grep -v /vendor/)

bump:
	pip install --upgrade bumpversion
	bumpversion ${TYPE}

$(ARTIFACTS)/all: $(ARTIFACTS)/emp-Linux-x86_64 $(ARTIFACTS)/emp-Darwin-x86_64 $(ARTIFACTS)/empire-Linux-x86_64

$(ARTIFACTS)/emp-Linux-x86_64:
	env GOOS=linux go build -o $@ ./cmd/emp
$(ARTIFACTS)/emp-Darwin-x86_64:
	env GOOS=darwin go build -o $@ ./cmd/emp

$(ARTIFACTS)/empire-Linux-x86_64:
	env GOOS=linux go build -o $@ ./cmd/empire
