# Utility rules to run automation tasks

.PHONY: all tests parsers-tests php-tests xsh-tests xslt-tests

all: tests

tests: parsers-tests php-tests xsh-tests xslt-tests

parsers-tests:
	@tools/sh/run-tests.sh parsers
	
php-tests:
	@tools/sh/run-tests.sh php
	
xsh-tests:
	@tools/sh/run-tests.sh xsh
	
xslt-tests:
	@tools/sh/run-tests.sh xslt