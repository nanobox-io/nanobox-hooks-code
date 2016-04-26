
stable:
	@./util/publish.sh stable

beta:
	@./util/publish.sh beta

alpha:
	@./util/publish.sh alpha

all: stable
