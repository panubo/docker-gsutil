TAG        := latest
VERSION    := $(shell sed -E -e '/GSUTIL_VERSION[ |=]/!d' -e 's/.*GSUTIL_VERSION[ |=|v]+([0-9\.]+).*/\1/' Dockerfile)
IMAGE_NAME := panubo/gsutil
REGISTRY   := docker.io

AWS_DEFAULT_REGION := ap-southeast-2

build:
	docker build -t ${IMAGE_NAME}:${TAG} .

bash:
	docker run --rm -it ${IMAGE_NAME}:${TAG}

bash-aws:
	@printf "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}\nAWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\nAWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\nAWS_SECURITY_TOKEN=${AWS_SESSION_TOKEN}\n" > make.env
	docker run --rm -it -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --env-file ./make.env ${IMAGE_NAME}:${TAG}
	-rm ./make.env

test: build
	docker run --rm -it --env-file test.env ${IMAGE_NAME}:${TAG} diff -u /home/user/.boto.tmpl /home/user/.boto

publish: REVISION_CURRENT ?= $(shell skopeo inspect docker://docker.io/panubo/gsutil | jq -r '.RepoTags[]' | sort | grep "4.36" | tail -n1 | sed -E 's/.*-([0-9]+)/\1/')
publish: REVISION ?= $(shell echo $$(($(REVISION_CURRENT) + 1)))
publish:
	docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}
	docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${VERSION}-${REVISION}
	docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${VERSION}
	docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}
	docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}-${REVISION}
	docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}
