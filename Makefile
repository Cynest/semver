SHELL := /bin/bash

depcheck: ## Get the dependencies
	@go get -u -v github.com/golang/dep/cmd/dep
	@dep check

dep: ## Get the dependencies
	@go get -u -v github.com/golang/dep/cmd/dep
	@dep ensure -vendor-only

.ONESHELL:
lint: ## Go lint the files
	@PKG_LIST=$$(go list ./... | grep -v /vendor/)
	@golint -set_exit_status $$PKG_LIST

fmt: ## Go fmt the files
	@gofmt -d *.go

vet: ## Go vet the files
	@go vet *.go

releaseinfo: ## Generate changelog and version.env files in releaseinfo folder
	@mkdir -p releaseinfo
	@./changelog -l > releaseinfo/CHANGELOG
	@./version > releaseinfo/version.env

githubrelease: ## Create or Edit github release and upload rpm files if present
	@./release_to_github.sh $(prefix)

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
