# Utility rules to run automation tasks

ARGS :=
ifdef STDERR
	ARGS += --stderr $(STDERR)
endif
ifdef STDOUT
	ARGS += --stdout $(STDOUT)
endif

.PHONY: all tests parsers-tests php-tests xsh-tests xslt-tests

all: tests

tests: parsers-tests php-tests xsh-tests xslt-tests

parsers-tests:
	@echo Parsers
	@tools/sh/run-tests.sh parsers
	
php-tests:
	@echo PHP
	@tools/sh/run-tests.sh php
	
xsh-tests:
	@echo XSH library
	@tools/sh/run-tests.sh xsh $(ARGS)
	
xslt-tests:
	@echo XSLT library
	@tools/sh/run-tests.sh xslt
