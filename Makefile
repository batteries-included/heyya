.PHONY: deps compile test lint analyze docs

all: deps compile test lint format docs analyze

deps:
	mix deps.get

compile: $(wildcard **/*.ex **/*.exs)
	mix compile --force --warnings-as-errors

test:
	mix test

lint:
	mix credo

analyze:
	mix dialyzer

docs:
	mix docs

format: $(wildcard **/*.ex **/*.exs)
	mix format 