export IMAGE_NAME?=insightful/alpine-node
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/insightfulsystems/alpine-node
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
export TAG_DATE=`date -u +"%Y%m%d"`
export ALPINE_VERSION=3.12.3
export QEMU_VERSION=5.1.0-8
export BASE_IMAGE=alpine
export BUILD_IMAGE=local/alpine-base
export NODE_MAJOR_VERSION=14
export NODE_VERSION=14.15.3
export YARN_VERSION=1.22.5
export TARGET_ARCHITECTURES=amd64 arm32v6 arm32v7 arm64v8
export QEMU_ARCHITECTURES=arm aarch64
export SHELL=/bin/bash

# Permanent local overrides
-include .env

.PHONY: qemu wrap build push manifest clean

qemu:
	@echo "==> Setting up QEMU"
	docker pull multiarch/qemu-user-static:register
	-docker run --rm --privileged multiarch/qemu-user-static:register --reset
	-mkdir tmp
	$(foreach ARCH, $(QEMU_ARCHITECTURES), make fetch-qemu-$(ARCH);)
	@echo "==> Done setting up QEMU"

fetch-qemu-%:
	$(eval ARCH := $*)
	@echo "--> Fetching QEMU binary for $(ARCH)"
	cd tmp && \
	curl -L -o qemu-$(ARCH)-static.tar.gz \
		https://github.com/multiarch/qemu-user-static/releases/download/v$(QEMU_VERSION)/qemu-$(ARCH)-static.tar.gz && \
	tar xzf qemu-$(ARCH)-static.tar.gz && \
	cp qemu-$(ARCH)-static ../qemu/
	@echo "--> Done."

wrap:
	@echo "==> Building local base containers"
	$(foreach ARCH, $(TARGET_ARCHITECTURES), make wrap-$(ARCH);)
	@echo "==> Done."

wrap-amd64:
	docker pull amd64/$(BASE_IMAGE):$(ALPINE_VERSION)
	docker tag amd64/$(BASE_IMAGE):$(ALPINE_VERSION) $(BUILD_IMAGE):amd64

wrap-translate-%: 
	@if [[ "$*" == "arm64v8" ]] ; then \
	   echo "aarch64"; \
	else \
		echo "arm"; \
	fi 

wrap-%:
	$(eval ARCH := $*)
	@echo "--> Building local base container for $(ARCH)"
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg ARCH=$(shell make -s wrap-translate-$(ARCH)) \
		--build-arg BASE=$(ARCH)/$(BASE_IMAGE):$(ALPINE_VERSION) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		-t $(BUILD_IMAGE):$(ARCH) qemu
	@echo "--> Done building local base container for $(ARCH)"

build:
	$(foreach var, $(TARGET_ARCHITECTURES), make build-$(var);)

build-%: # This assumes we have a folder for each major version
	$(eval ARCH := $*)
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg ARCH=$(ARCH) \
		--build-arg BASE=$(BUILD_IMAGE):$(ARCH) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg YARN_VERSION=$(YARN_VERSION) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		-t $(IMAGE_NAME):$(NODE_MAJOR_VERSION)-$(ARCH) $(NODE_MAJOR_VERSION)
	echo "\n---\nDone building $(ARCH)\n---\n"

push:
	docker push $(IMAGE_NAME)

push-%:
	$(eval ARCH := $*)
	docker push $(IMAGE_NAME):$(NODE_MAJOR_VERSION)-$(ARCH)

expand-%: # expand architecture variants for manifest
	@if [ "$*" == "amd64" ] ; then \
	   echo '--arch $*'; \
	elif [[ "$*" == *"arm"* ]] ; then \
	   echo '--arch arm --variant $*' | cut -c 1-21,27-; \
	fi

manifest:
	@echo "==> Building multi-architecture manifest"
	$(foreach STEP, build push, make $(STEP)-manifest;)
	@echo "==> Done."	

build-manifest:
	@echo "--> Creating manifest"
	docker manifest create --amend \
		$(IMAGE_NAME):latest \
		$(foreach arch, $(TARGET_ARCHITECTURES), $(IMAGE_NAME):$(NODE_MAJOR_VERSION)-$(arch) )
	$(foreach arch, $(TARGET_ARCHITECTURES), \
		docker manifest annotate \
			$(IMAGE_NAME):latest \
			$(IMAGE_NAME):$(NODE_MAJOR_VERSION)-$(arch) $(shell make -s expand-$(arch));)


push-manifest:
	@echo "--> Pushing manifest"
	docker manifest push $(IMAGE_NAME):latest

all: qemu wrap build push manifest push-manifest

clean:
	@echo "==> Cleaning up old images..."
	-docker rm -fv $$(docker ps -a -q -f status=exited)
	-docker rmi -f $$(docker images -q -f dangling=true)
	-docker rmi -f $(BASE_IMAGE)
	-docker rmi -f $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(IMAGE_NAME))
	@echo "==> Done."
