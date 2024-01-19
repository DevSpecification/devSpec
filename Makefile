.PHONY:dependencies
dependencies:
	git clone --recurse-submodules https://github.com/google/docsy.git themes/doscy
	cd themes/doscy
	git checkout 5597d435dc74ce68240e0c3871addf24567493b0

.PHONY:docker-compose
docker-compose:
	docker-compose up --build

.PHONY:build
build:
	docker-compose up --build
