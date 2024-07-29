.PHONY: test lint analyze docs i

all: deps compile test format

deps:
	mix deps.get

compile:
	mix compile --force --warnings-as-errors

test:
	mix test

format:
	mix format 