SUBSCRIPTION := 24d1df90-df6d-4d34-9f8d-e4bbb9c5e9e4
BICEP_FILE := 'azuredeploy.bicep'
MODULE_NAME :=
VERSION :=

RUNID := $(shell date +%F.%H-%M-%S)

ifeq ($(MODULE_NAME),)
$(error MODULE_NAME is not set)
endif

ifeq ($(VERSION),)
$(error VERSION is not set)
endif

ifneq ("$(wildcard $(BICEP_FILE))","")
FILE_EXISTS = 1
else
$(error no FILE at target ${BICEP_FILE})
endif

setversion:
	@echo "Setting version to $(VERSION)"
	@sed -i '/^\/\/ V.*/d' $(BICEP_FILE)
	@sed -i '1 i\// Version $(VERSION)' $(BICEP_FILE)

publish.prod: setversion
	@echo "publishing Bicep to PROD bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesPROD:$(MODULE_NAME):$(VERSION)

publish.dev: setversion
	@echo "publishing Bicep to DEV bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesDEV:$(MODULE_NAME):$(VERSION) 
