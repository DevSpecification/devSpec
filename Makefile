.PHONY:dependencies
dependencies:
	git clone --recurse-submodules https://github.com/google/docsy.git themes/doscy
	cd themes/doscy
	git submodule foreach 'git checkout tags/v0.6.0 || :'

.PHONY:docker-compose
docker-compose:
	docker-compose up --build

.PHONY:build
build:
	docker-compose up --build
