.PHONY:dependencies
dependencies:
	git clone --recurse-submodules --depth 1 https://github.com/google/docsy.git themes/doscy

.PHONY:docker-compose
docker-compose:
	docker-compose up --build

.PHONY:build
build:
	docker-compose up --build