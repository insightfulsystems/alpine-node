# Base `node` Docker images

[![Docker Stars](https://img.shields.io/docker/stars/insightful/alpine-python.svg)](https://hub.docker.com/r/insightful/alpine-python)
[![Docker Pulls](https://img.shields.io/docker/pulls/insightful/alpine-python.svg)](https://hub.docker.com/r/insightful/alpine-python)
[![](https://images.microbadger.com/badges/image/insightful/alpine-python.svg)](https://microbadger.com/images/insightful/alpine-python "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/insightful/alpine-python.svg)](https://microbadger.com/images/insightful/alpine-python "Get your own version badge on microbadger.com")
[![Build Status](https://dev.azure.com/ruicarmo/ruicarmo/_apis/build/status/insightfulsystems.alpine-node?branchName=master)](https://dev.azure.com/ruicarmo/ruicarmo/_build/latest?definitionId=1&branchName=master)

Now based on the official `alpine`-based images and [`alpine-python`](https://github.com/insightfulsystems/alpine-python) multiarch approach, but targeting _only_ LTS releases.

Current tags:

* `insightful/alpine-node:latest`, which is a virtual image for
	* `insightful/alpine-node:10-amd64` (currently at `v10.16.0`)
	* `insightful/alpine-node:10-arm32v6`
	* `insightful/alpine-node:10-arm32v7`

All tags have a full install with `npm` and `yarn`.
