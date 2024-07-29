.PHONY: test lint analyze docs i

all: deps compile test lint format docs analyze

deps:
	mix deps.get

compile:
	mix compile --force --warnings-as-errors

test:
	mix test

lint:
	mix credo

analyze:
	mix dialyzer

docs:
	mix docs

format:
	mix format 