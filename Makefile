
stable:
	@./util/publish.sh stable

beta:
	@./util/publish.sh beta

alpha:
	@./util/publish.sh alpha

all: stable

.PHONY: test

test:
	stdbuf -oL test/run_all.sh
