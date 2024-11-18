SUBSCRIPTION := 24d1df90-df6d-4d34-9f8d-e4bbb9c5e9e4
BICEP_FILE := 'azuredeploy.bicep'
MODULE_NAME :=
VERSION :=
FORCE := 0
RUNID := $(shell date +%F.%H-%M-%S)

.PHONY: help publish.prod publish.dev setversion


help:
	@echo "Usage: make publish.prod BICEP_FILE=<bicep_filepath> MODULE_NAME=<module_name> VERSION=<version> [FORCE=1]"
	@echo "Usage: make publish.dev BICEP_FILE=<bicep_filepath> MODULE_NAME=<module_name> VERSION=<version> [FORCE=1]"
	@echo "Usage: make setversion VERSION=<version>"
	@echo "\nBICEP_FILE: The path to the Bicep file to publish, e.g. './resources/resouceRedis/azuredeploy.bicep'"
	@echo "MODULE_NAME: The name of the module to publish, e.g. 'appserviceplan' or 'storageaccount'"
	@echo "VERSION: The version of the module to publish, e.g. '1.0' or '1.1'"
	@echo "FORCE: Optional. If set to 1, will overwrite existing versions in the registry"
	@echo "\nExample: make publish.dev BICEP_FILE=./resources/resourceAppServicePlan/azuredeploy.bicep MODULE_NAME=appserviceplan VERSION=1.0"


ifneq ("$(FORCE)","1")
override undefine FORCE
else
$(info FORCE is set. This will overwrite existing versions)
endif

# ifneq ("$(wildcard $(BICEP_FILE))","")
# FILE_EXISTS = 1
# else
# $(error no FILE at target ${BICEP_FILE})
# endif

# ifeq ($(MODULE_NAME),)
# $(error MODULE_NAME is not set)
# endif

validate:
	@echo "Validating Bicep file"
	@if [ -f ${BICEP_FILE} ]; then\
		FILE_EXISTS=1;\
		echo "FILE exists at target ${BICEP_FILE}";\
	else\
		echo no FILE at target ${BICEP_FILE};\
		exit 1;\
	fi
	@if [ -z ${MODULE_NAME} ]; then\
		echo MODULE_NAME is not set;\
		exit 1;\
	fi
	@if [ -z $(VERSION) ]; then\
		echo VERSION is not set;\
		exit 1;\
	fi
	az bicep lint --file $(BICEP_FILE) --no-restore

setversion:
	@echo "Setting version to $(VERSION)"
	@sed -i '/^\/\/ Ver.*/d' $(BICEP_FILE)
	@sed -i '1 i\// Version $(VERSION)' $(BICEP_FILE)
	# This won't work with mac sed. use GNU sed instead:
	# brew install gnu-sed
	# PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"     (put this line in your .zshrc or whatever to always have gnu sed as your sed) 

publish.prod: validate setversion
	@echo "publishing Bicep to PROD bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesPROD:$(MODULE_NAME):$(VERSION) \
	$(if $(FORCE),--force,)

publish.dev: validate setversion
	@echo "publishing Bicep to DEV bicep registry"
	az bicep publish \
	--file $(BICEP_FILE) \
	--target br/CoreModulesDEV:$(MODULE_NAME):$(VERSION) \
	$(if $(FORCE),--force,)