SUBSCRIPTION        := 24d1df90-df6d-4d34-9f8d-e4bbb9c5e9e4
BICEP_FILE := ''
MODULE_NAME := ''
VERSION := 0.1

RUNID := $(shell date +%F.%H-%M-%S)

publish.prod:
	@echo "publishing Bicep to PROD bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesPROD:$(MODULE_NAME):$(VERSION)

publish.dev:
	@echo "publishing Bicep to DEV bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesDEV:$(MODULE_NAME):$(VERSION)
