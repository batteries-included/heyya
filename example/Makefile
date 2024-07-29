.PHONY: deps compile test

all: deps compile test format

deps:
	mix deps.get

compile: $(wildcard **/*.ex **/*.exs)
	mix compile --force --warnings-as-errors

test:
	mix test

format: $(wildcard **/*.ex **/*.exs)
	mix format 