.DEFAULT_GOAL := help
.PHONY: help

include .env
export

PY?=python3
PELICAN?=pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py


BLOG_COMPOSE_FILE := docker-compose.dev.yml


DEBUG ?= 0
ifeq ($(DEBUG), 1)
	PELICANOPTS += -D
endif

RELATIVE ?= 0
ifeq ($(RELATIVE), 1)
	PELICANOPTS += --relative-urls
endif

help: ## Print this help
	@echo 'Makefile for a pelican Web site'
	@echo ''
	@echo 'Set the DEBUG variable to 1 to enable debugging, e.g. make DEBUG=1 html'
	@echo 'Set the RELATIVE variable to 1 to enable relative urls'
	@echo ''
	@grep -E '^[0-9a-zA-Z_\-\.]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


html: ## (re)generate the web site
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean: ## remove the generated files
	[ ! -d $(OUTPUTDIR) ] || rm -rf $(OUTPUTDIR)

regenerate: ## regenerate files upon modification
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve: ## serve site at http://localhost:8000
ifdef PORT
	$(PELICAN) --listen $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT)
else	
	$(PELICAN) --listen $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)
endif

serve-global: ## serve (as root) to $(SERVER):80
ifdef SERVER
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT) -b $(SERVER)
	# $(PELICAN) -l $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT) -b $(SERVER)
else
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT) -b 0.0.0.0
endif


devserver: ## serve and regenerate together
ifdef PORT
	$(PELICAN) -lr $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -p $(PORT) -b 0.0.0.0
else
	$(PELICAN) -lr $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS) -b 0.0.0.0
endif

publish: ## generate html using production settings
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

requirements.txt: ## generate requirements.txt and requirements-dev.txt from pyproject.toml using poetry
	poetry export -f requirements.txt --without-hashes --only main -o requirements.txt &&\
	poetry export -f requirements.txt --without-hashes --only dev -o requirements-dev.txt 

docker.publish: ## runs make publish from docker
	docker compose -f docker-compose.dev.yml run --rm  --entrypoint make blog publish

docker.html: ## runs make html from docker
	docker compose -f docker-compose.dev.yml run --rm  --entrypoint make blog html

docker.serve: ## runs make html from docker
	docker compose -f docker-compose.dev.yml run --rm  --service-ports --entrypoint make blog devserver

