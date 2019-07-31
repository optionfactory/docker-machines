SCM_SERVICE={{SCM_SERVICE}}
SCM_TEAM={{SCM_TEAM}}
PROJECT={{PROJECT}}
DISTRO={{DISTRO}}
UID=$(shell id -u)
GID=$(shell id -g)
VERSION=$(shell git describe --always)
SHELL=/bin/bash
GOBIN=go
ROOTS=
#e.g: TOOLS_TO_INSTALL=github.com/jteeuwen/go-bindata golang.org/x/tools/cmd/stringer
TOOLS_TO_INSTALL=
GODEPS_CACHE_FOLDER=${PWD}/../godeps/
BUILD_OS=linux
BUILD_ARCH=amd64

docker-local: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER):/go/ \
		-v ${PWD}/:/project/ \
		-w /project/ \
		optionfactory/$(DISTRO)-golang1:latest \
		make $(PROJECT)-$(BUILD_OS)-$(BUILD_ARCH) UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}

docker-all: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER):/go/ \
		-v ${PWD}/:/project/ \
		-w /project/ \
		optionfactory/$(DISTRO)-golang1:latest \
		make build UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}

docker-bootstrap-module: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER):/go/ \
		-v ${PWD}/:/project/ \
		-w /project/ \
		optionfactory/$(DISTRO)-golang1:latest \
		make bootstrap-module UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}

bootstrap-module:
	go mod init $(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)
	@chown ${UID}:${GID} go.mod

build: $(PROJECT)-linux-amd64 $(PROJECT)-windows-amd64

$(PROJECT)-linux-%: GOOS = linux
$(PROJECT)-windows-%: GOOS = windows
$(PROJECT)-windows-%: EXT = .exe

$(PROJECT)-%-amd64: GOARCH = amd64

$(PROJECT)-%: FORCE
	@echo gofmt: reformatting
	@gofmt -w=true -s=true .
	@for TOOL in ${TOOLS_TO_INSTALL}; do \
		echo "$(GOBIN) get tool $${TOOL} for $(GOOS):$(GOARCH)"; \
		echo GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) get -u $${TOOL}/...; \
	done
	@echo "$(GOBIN) generate for $(GOOS):$(GOARCH)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) generate ./...
	@echo "$(GOBIN) get for $(GOOS):$(GOARCH)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) get ./...;
	@if [ "${GOOS}" == "${BUILD_OS}" -a "${GOARCH}" == "${BUILD_ARCH}" ] ; then \
		echo "$(GOBIN) vet for $(GOOS):$(GOARCH)"; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) vet ./...; \
		echo "$(GOBIN) test for $(GOOS):$(GOARCH)"; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) test -a $(TESTING_OPTIONS) -ldflags "-X main.version=$(VERSION)" ./...; \
	fi
	@echo building for $(GOOS):$(GOARCH) in ${BUILD_OS}:${BUILD_ARCH}
	@touch /go/.buildtimestamp
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) install -a -ldflags "-X main.version=$(VERSION)" $(ROOTS)
	@find /go/bin -type f -newer /go/.buildtimestamp -exec cp {} /project/bin/ \;
	@chown -R ${UID}:${GID} /project/bin/
	@rm /go/.buildtimestamp


clean:
	-rm -f bin/$(PROJECT)*
clean-deps:
	-rm -f ../godeps/*
FORCE:
