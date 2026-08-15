# API(Go)
run-api:
	go run apps/cmd/kosu

lint-write-api:
	go fmt ./...
	go vet ./...
