# API(Go)
run-api:
	go run apps/cmd/kosu

lint-write-api:
	go fmt ./...
	go vet ./...

# Jujutsu
.PHONY: jj-commit jj-push

jj-commit:
	@test -n "$(m)" || (echo 'Usage: make jj-commit MESSAGE="commit message"' && exit 1)
	jj commit -m "$(m)"

jj-push:
	jj bookmark set $(bm) -r @-
	jj git push --bookmark $(bm)
