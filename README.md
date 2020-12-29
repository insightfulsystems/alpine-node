# Base `node` Docker images

[![Docker Stars](https://img.shields.io/docker/stars/insightful/alpine-node.svg)](https://hub.docker.com/r/insightful/alpine-node)
[![Docker Pulls](https://img.shields.io/docker/pulls/insightful/alpine-node.svg)](https://hub.docker.com/r/insightful/alpine-node)
[![](https://images.microbadger.com/badges/image/insightful/alpine-node.svg)](https://microbadger.com/images/insightful/alpine-node "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/insightful/alpine-node.svg)](https://microbadger.com/images/insightful/alpine-node "Get your own version badge on microbadger.com")

Now based on the official `alpine`-based images and [alpine-python](https://github.com/insightfulsystems/alpine-python) multiarch approach, but targeting _only_ LTS releases.

Current tags:

* `insightful/alpine-node:latest`, which is a virtual image for
	* `insightful/alpine-node:14-amd64` (currently at `v14.15.3)
	* `insightful/alpine-node:14-arm32v6`
	* `insightful/alpine-node:14-arm32v7`
	* `insightful/alpine-node:14-arm64v8`

All tags have a full install with `npm` and `yarn`.

Due to the long time required to build the ARM versions (well over 4 hours on typical build agents), this repository cannot be built automatically on the free tiers of either Travis CI or Azure Pipelines and is manually refreshed every three months. 
