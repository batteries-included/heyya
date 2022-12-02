.PHONY: test lint analyze docs i

all: test format docs analyze

test:
	mix test

analyze:
	mix dialyzer

docs:
	mix docs

format:
	mix format 