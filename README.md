# Base `node` Docker images

[![Docker Stars](https://img.shields.io/docker/stars/insightful/alpine-node.svg)](https://hub.docker.com/r/insightful/alpine-node)
[![Docker Pulls](https://img.shields.io/docker/pulls/insightful/alpine-node.svg)](https://hub.docker.com/r/insightful/alpine-node)
[![](https://images.microbadger.com/badges/image/insightful/alpine-node.svg)](https://microbadger.com/images/insightful/alpine-node "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/insightful/alpine-node.svg)](https://microbadger.com/images/insightful/alpine-node "Get your own version badge on microbadger.com")
[![Build Status](https://dev.azure.com/ruicarmo/insightfulsystems/_apis/build/status/insightfulsystems.alpine-node?branchName=master)](https://dev.azure.com/ruicarmo/insightfulsystems/_build/latest?definitionId=1&branchName=master)

Now based on the official `alpine`-based images and [`alpine-python`](https://github.com/insightfulsystems/alpine-python) multiarch approach, but targeting _only_ LTS releases.

Current tags:

* `insightful/alpine-node:latest`, which is a virtual image for
	* `insightful/alpine-node:10-amd64` (currently at `v10.16.3`)
	* `insightful/alpine-node:10-arm32v6`
	* `insightful/alpine-node:10-arm32v7`
	* `insightful/alpine-node:10-arm64v8`

All tags have a full install with `npm` and `yarn`.
