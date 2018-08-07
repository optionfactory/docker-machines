SCM_SERVICE={{SCM_SERVICE}}
SCM_TEAM={{SCM_TEAM}}
PROJECT={{PROJECT}}
DISTRO={{DISTRO}}
UID=$(shell id -u)
GID=$(shell id -g)
VERSION=$(shell git describe --always)
SHELL = /bin/bash
TOOLS_TO_INSTALL=github.com/jteeuwen/go-bindata golang.org/x/tools/cmd/stringer
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


local: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER):/go/src/ \
		-v ${PWD}/:/go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		-v ${PWD}/Makefile:/go/Makefile \
		-v ${PWD}/bin:/go/bin \
		-w /go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		optionfactory/$(DISTRO)-golang1:latest \
		make -f /go/Makefile $(PROJECT)-$(BUILD_OS)-$(BUILD_ARCH) UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}


all: FORCE
	@echo spawning docker container
	@docker run --rm=true \
		-v $(GODEPS_CACHE_FOLDER):/go/src/ \
		-v ${PWD}/:/go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
		-v ${PWD}/Makefile:/go/Makefile \
		-v ${PWD}/bin:/go/bin \
		-w /go/src/$(SCM_SERVICE)/$(SCM_TEAM)/$(PROJECT)/ \
        optionfactory/$(DISTRO)-golang1:latest \
		make -f /go/Makefile build UID=${UID} GID=${GID} VERSION=${VERSION} BUILD_OS=${BUILD_OS} BUILD_ARCH=${BUILD_ARCH} TESTING_OPTIONS=${TESTING_OPTIONS}

build: $(PROJECT)-linux-amd64 $(PROJECT)-windows-amd64

$(PROJECT)-linux-%: GOOS = linux
$(PROJECT)-windows-%: GOOS = windows
$(PROJECT)-windows-%: EXT = .exe

$(PROJECT)-%-amd64: GOARCH = amd64

$(PROJECT)-%: reformat gogetandgenerate-% tests-% *.go
	@echo building for $(GOOS):$(GOARCH) in ${BUILD_OS}:${BUILD_ARCH}
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go install -a -ldflags "-X main.version=$(VERSION)"
	@if [ "${GOOS}" == "${BUILD_OS}" -a "${GOARCH}" == "${BUILD_ARCH}" ] ; then \
		mv "/go/bin/${PROJECT}${EXT}" "/go/bin/${PROJECT}-${GOOS}-${GOARCH}${EXT}"; \
	else \
		mv "/go/bin/$(GOOS)_$(GOARCH)/$(PROJECT)$(EXT)" "/go/bin/$(PROJECT)-$(GOOS)-$(GOARCH)$(EXT)"; \
		rm -rf "/go/bin/${GOOS}_${GOARCH}/"; \
	fi
	@chown ${UID}:${GID} "/go/bin/${PROJECT}-${GOOS}-${GOARCH}${EXT}"
	@echo ""

reformat:
	@echo gofmt: reformatting
	@gofmt -w=true -s=true .

gogetandgenerate-%:
	@for TOOL in ${TOOLS_TO_INSTALL}; do \
		echo "go get tool $${TOOL} for $(GOOS):$(GOARCH)"; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go get -u $${TOOL}/...; \
	done
	@echo "go generate for $(GOOS):$(GOARCH)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go generate ./...
	@echo "go get for $(GOOS):$(GOARCH)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go get ./...

tests-%: FORCE
	@echo "go test for $(GOOS):$(GOARCH)"
	@if [ "${GOOS}" == "${BUILD_OS}" -a "${GOARCH}" == "${BUILD_ARCH}" ] ; then \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go vet ./...; \
		GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 go test -a $(TESTING_OPTIONS) -ldflags "-X main.version=$(VERSION)" ./...; \
	fi

clean:
	-rm -f bin/$(PROJECT)*
clean-deps:
	-rm -f ../godeps/*
FORCE:
