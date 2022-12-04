.PHONY: test lint analyze docs i

all: test lint format docs analyze

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