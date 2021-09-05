# Utility rules to run automation tasks

.PHONY: all tests parser-tests xsh-tests xslt-tests

all: tests

tests: parser-tests xsh-tests xslt-tests

parser-tests:
	@tools/sh/run-tests.sh parsers
	
xsh-tests:
	@tools/sh/run-tests.sh xsh
	
xslt-tests:
	@tools/sh/run-tests.sh xslt