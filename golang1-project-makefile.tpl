SCM_SERVICE={{SCM_SERVICE}}
SCM_TEAM={{SCM_TEAM}}
PROJECT={{PROJECT}}
DISTRO={{DISTRO}}
UID=$(shell id -u)
GID=$(shell id -g)
VERSION=$(shell git describe --always)
SHELL = /bin/bash
GOBIN=vgo
ROOTS=
#e.g: TOOLS_TO_INSTALL=github.com/jteeuwen/go-bindata golang.org/x/tools/cmd/stringer
TOOLS_TO_INSTALL=
GODEPS_CACHE_FOLDER=${PWD}/../godeps/

ifeq ($(OS),Windows_NT)
    BUILD_OS = windows
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        BUILD_ARCH = amd64
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        BUILD_ARCH = 386
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        BUILD_OS = linux
    endif
    ifeq ($(UNAME_S),Darwin)
        BUILD_OS = darwin
    endif

    ifneq ("$(shell which arch)","")
    	UNAME_P := $(shell arch)
    else
	    UNAME_P := $(shell uname -p)
	endif

    ifeq ($(UNAME_P),x86_64)
        BUILD_ARCH = amd64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        BUILD_ARCH = 386
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        BUILD_ARCH = arm
    endif
endif

devel: FORCE
	@echo spawning docker container
	-xhost local:
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER)/src:/go/src/ \
		-v $(GODEPS_CACHE_FOLDER)/pkg:/go/pkg/ \
		-v ${PWD}/:/go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		-v ${PWD}/bin:/output/ \
		-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
		-v /dev/shm:/dev/shm \
		-e DISPLAY \
		-w /go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		optionfactory/$(DISTRO)-golang1-atom1 /usr/bin/atom -f

local: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER)/src:/go/src/ \
		-v $(GODEPS_CACHE_FOLDER)/pkg:/go/pkg/ \
		-v ${PWD}/:/go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		-v ${PWD}/bin:/output/ \
		-w /go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		optionfactory/$(DISTRO)-golang1:latest \
		make $(PROJECT)-$(BUILD_OS)-$(BUILD_ARCH) UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}


all: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER)/src:/go/src/ \
		-v $(GODEPS_CACHE_FOLDER)/pkg:/go/pkg/ \
		-v ${PWD}/:/go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		-v ${PWD}/bin:/output/ \
		-w /go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		optionfactory/$(DISTRO)-golang1:latest \
		make build UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}

build: $(PROJECT)-linux-amd64 $(PROJECT)-windows-amd64

$(PROJECT)-linux-%: GOOS = linux
$(PROJECT)-windows-%: GOOS = windows
$(PROJECT)-windows-%: EXT = .exe

$(PROJECT)-%-amd64: GOARCH = amd64

$(PROJECT)-%: FORCE
	@touch /go/.buildtimestamp
	@echo gofmt: reformatting
	@gofmt -w=true -s=true .
	@for TOOL in ${TOOLS_TO_INSTALL}; do \
		echo "$(GOBIN) get tool $${TOOL} for $(GOOS):$(GOARCH)"; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) get -u $${TOOL}/...; \
	done
	@echo "$(GOBIN) generate for $(GOOS):$(GOARCH)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) generate ./...
	@echo "$(GOBIN) get for $(GOOS):$(GOARCH)"
	@if [ "vgo" != "$(GOBIN)" ] ; then \
	   @GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) get ./...; \
    fi
	@if [ "${GOOS}" == "${BUILD_OS}" -a "${GOARCH}" == "${BUILD_ARCH}" ] ; then \
		echo "$(GOBIN) vet for $(GOOS):$(GOARCH)"; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) vet ./...; \
		echo "$(GOBIN) test for $(GOOS):$(GOARCH)"; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) test -a $(TESTING_OPTIONS) -ldflags "-X main.version=$(VERSION)" ./...; \
	fi
	@echo building for $(GOOS):$(GOARCH) in ${BUILD_OS}:${BUILD_ARCH}
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 $(GOBIN) install -a -ldflags "-X main.version=$(VERSION)" $(ROOTS)
    @chown ${UID}:${GID} go.mod go.sum
	@find /go/bin -type f -newer /go/.buildtimestamp -exec chown ${UID}:${GID} {} \; -exec cp {} /output/ \;


clean:
	-rm -f bin/$(PROJECT)*
clean-deps:
	-rm -f ../godeps/*
FORCE:
