# Base `node` Docker images

Now based on the official `alpine`-based images and [`alpine-python`](https://github.com/insightfulsystems/alpine-python) multiarch approach, but targeting _only_ LTS releases.

Current tags:

* `insightful/alpine-node:latest`, which is a virtual image for
	* `insightful/alpine-node:10-amd64` (currently at `v10.15.3`)
	* `insightful/alpine-node:10-arm32v6`
	* `insightful/alpine-node:10-arm32v7`

All tags have a full install with `npm` and `yarn`.
