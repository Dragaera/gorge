.PHONY: build push clean tag release

IMAGE_NAME = lavode/gorge
SENTRY_PROJECT = observatory
SENTRY_ORGANIZATION = dragaera
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

tag:
	@echo 'Checking for unstashed changes.'
	! git status --porcelain 2>/dev/null | grep '^ M '
	@echo 'None found.'
	
	@echo 'Checking for untracked files'
	! git status --porcelain 2>/dev/null | grep '^?? '
	@echo 'None found.'
	
	@echo "Building release: ${VERSION}"
	sed -E -i "s/VERSION = '([0-9.]+)'/VERSION = '${VERSION}'/" lib/gorge/version.rb
	vim CHANGELOG.md
	git add lib/gorge/version.rb CHANGELOG.md
	git commit -m "Bump version to '${VERSION}'."
	git tag -a ${VERSION}
	git push
	git push --tags

	SENTRY_ORG=${SENTRY_ORGANIZATION} sentry-cli releases new -p ${SENTRY_PROJECT} ${VERSION}
	SENTRY_ORG=${SENTRY_ORGANIZATION} sentry-cli releases set-commits --auto ${VERSION}

release: tag push
