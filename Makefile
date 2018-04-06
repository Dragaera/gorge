.PHONY: build push

IMAGE_NAME = lavode/gorge
COMMIT_ID := $(shell git rev-parse HEAD)

build:
	@echo "Building container for commit ${COMMIT_ID}"
	echo ${COMMIT_ID} > image_version
	echo ${IMAGE_NAME} > image_name
	docker build -t ${IMAGE_NAME}:${COMMIT_ID} .
	docker build -t ${IMAGE_NAME}:latest .

push: build
	IMAGE_NAME=${IMAGE_NAME} util/push_container.sh

clean:
	@echo "Cleaning application environment"
	docker-compose down -v
