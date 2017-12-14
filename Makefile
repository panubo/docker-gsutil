TAG        := latest
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

push:
	docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}
	docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}
