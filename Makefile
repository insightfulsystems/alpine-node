export IMAGE_NAME?=insightful/alpine-node
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/insightfulsystems/alpine-node
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
export TAG_DATE=`date -u +"%Y%m%d"`
export ALPINE_VERSION=alpine:3.10
export QEMU_VERSION=4.0.0-2
export BUILD_IMAGE_NAME=local/alpine-base
export NODE_MAJOR_VERSION=10
export NODE_VERSION=10.15.3
export TARGET_ARCHITECTURES=amd64 arm32v6 arm32v7
export SHELL=/bin/bash

# Permanent local overrides
-include .env

.PHONY: qemu wrap build push manifest clean

qemu:
	-docker run --rm --privileged multiarch/qemu-user-static:register --reset
	-mkdir tmp 
	cd tmp && \
	curl -L -o qemu-arm-static.tar.gz https://github.com/multiarch/qemu-user-static/releases/download/v$(QEMU_VERSION)/qemu-arm-static.tar.gz && \
	tar xzf qemu-arm-static.tar.gz && \
	cp qemu-arm-static ../qemu/

wrap:
	$(foreach arch, $(TARGET_ARCHITECTURES), make wrap-$(arch);)

wrap-amd64:
	docker pull amd64/$(ALPINE_VERSION)
	docker tag amd64/$(ALPINE_VERSION) $(BUILD_IMAGE_NAME):amd64

wrap-%:
	$(eval ARCH := $*)
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg ARCH=$(ARCH) \
		--build-arg BASE=$(ARCH)/$(ALPINE_VERSION) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		-t $(BUILD_IMAGE_NAME):$(ARCH) qemu

build:
	$(foreach var, $(TARGET_ARCHITECTURES), make build-$(var);)

build-%: # This assumes we have a folder for each major version
	$(eval ARCH := $*)
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg ARCH=$(ARCH) \
		--build-arg BASE=$(BUILD_IMAGE_NAME):$(ARCH) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
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
	docker manifest create --amend \
		$(IMAGE_NAME):latest \
		$(foreach arch, $(TARGET_ARCHITECTURES), $(IMAGE_NAME):$(NODE_MAJOR_VERSION)-$(arch) )
	$(foreach arch, $(TARGET_ARCHITECTURES), \
		docker manifest annotate \
			$(IMAGE_NAME):latest \
			$(IMAGE_NAME):$(NODE_MAJOR_VERSION)-$(arch) $(shell make expand-$(arch));)
	docker manifest push $(IMAGE_NAME):latest

clean:
	-docker rm -fv $$(docker ps -a -q -f status=exited)
	-docker rmi -f $$(docker images -q -f dangling=true)
	-docker rmi -f $(BUILD_IMAGE_NAME)
	-docker rmi -f $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(IMAGE_NAME))

