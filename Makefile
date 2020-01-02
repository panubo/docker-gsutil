NAME := gsutil
TAG := latest
IMAGE_NAME := panubo/$(NAME)

AWS_DEFAULT_REGION := ap-southeast-2

.PHONY: help bash bash-aws test build push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

bash:
	docker run --rm -it ${IMAGE_NAME}:${TAG}

bash-aws:
	@printf "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}\nAWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}\nAWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}\nAWS_SECURITY_TOKEN=${AWS_SESSION_TOKEN}\n" > make.env
	docker run --rm -it -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) --env-file ./make.env ${IMAGE_NAME}:${TAG}
	-rm ./make.env

test: build
	docker run --rm -it --env-file test.env ${IMAGE_NAME}:${TAG} diff -u /home/user/.boto.tmpl /home/user/.boto

build: ## Builds docker image latest
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

push: ## Pushes the docker image to hub.docker.com
	docker push $(IMAGE_NAME):$(TAG)

clean: ## Remove built image
	docker rmi $(IMAGE_NAME):$(TAG)
