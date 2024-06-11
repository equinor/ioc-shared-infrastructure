SUBSCRIPTION := 24d1df90-df6d-4d34-9f8d-e4bbb9c5e9e4
BICEP_FILE := 'azuredeploy.bicep'
MODULE_NAME :=
VERSION :=
FORCE := 0
RUNID := $(shell date +%F.%H-%M-%S)

ifneq ("$(FORCE)","1")
override undefine FORCE
else
$(info FORCE is set. This will overwrite existing versions)
endif

ifeq ($(VERSION),)
$(error VERSION is not set)
endif

ifneq ("$(wildcard $(BICEP_FILE))","")
FILE_EXISTS = 1
else
$(error no FILE at target ${BICEP_FILE})
endif

ifeq ($(MODULE_NAME),)
$(error MODULE_NAME is not set)
endif

setversion:
	@echo "Setting version to $(VERSION)"
	@sed -i '/^\/\/ Ver.*/d' $(BICEP_FILE)
	@sed -i '1 i\// Version $(VERSION)' $(BICEP_FILE)
	# This won't work with mac sed. use GNU sed instead:
	# brew install gnu-sed
	# PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"     (put this line in your .zshrc or whatever to always have gnu sed as your sed) 

publish.prod: setversion
	@echo "publishing Bicep to PROD bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesPROD:$(MODULE_NAME):$(VERSION) \
	$(if $(FORCE),--force,)

publish.dev: setversion
	@echo "publishing Bicep to DEV bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesDEV:$(MODULE_NAME):$(VERSION) \
	$(if $(FORCE),--force,)