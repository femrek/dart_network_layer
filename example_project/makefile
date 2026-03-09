OPENAPI_CODEGEN_VERSION := 7.20.0
OPENAPI_CODEGEN_JAR := ./openapi-generator-cli-$(OPENAPI_CODEGEN_VERSION).jar
CUSTOM_CODEGEN_VERSION := 0.1.7
CUSTOM_CODEGEN_JAR := ./openapi-dart-network-codegen-$(CUSTOM_CODEGEN_VERSION).jar
SPEC_FILE_NAME := ./openapi-spec.json
SPEC_FILE_URL := https://dummyapi.femrek.dev/v3/api-docs
GENERATOR := dart-network

download-openapi-cli-if-not-exists:
	# Check if the OpenAPI Generator CLI jar file exists, and download it if it doesn't
	if [ ! -f $(OPENAPI_CODEGEN_JAR) ]; then \
	    echo "OpenAPI Generator CLI not found. Downloading..."; \
	    curl -fL -o $(OPENAPI_CODEGEN_JAR) https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$(OPENAPI_CODEGEN_VERSION)/openapi-generator-cli-$(OPENAPI_CODEGEN_VERSION).jar; \
	else \
	    echo "OpenAPI Generator CLI already exists."; \
	fi

download-codegen-if-not-exists:
	# Check if the custom code generator jar file exists, and download it if it doesn't
	if [ ! -f $(CUSTOM_CODEGEN_JAR) ]; then \
	    echo "Custom code generator not found. Downloading..."; \
	    curl -fL -o $(CUSTOM_CODEGEN_JAR) https://github.com/femrek/dart-network-openapi-codegen/releases/download/v${CUSTOM_CODEGEN_VERSION}/openapi-dart-network-codegen-${CUSTOM_CODEGEN_VERSION}.jar; \
	else \
	    echo "OpenAPI Generator CLI already exists."; \
	fi

download-openapi-spec:
	# Check if the OpenAPI spec file exists, and download it if it doesn't
	echo "OpenAPI spec file Downloading..."; \
	curl -fL -o $(SPEC_FILE_NAME) $(SPEC_FILE_URL); \

generate: download-openapi-cli-if-not-exists download-codegen-if-not-exists download-openapi-spec
	$(eval OUTPUT_DIR := ./modules/openapi)
	rm -rf $(OUTPUT_DIR)
	java -cp $(OPENAPI_CODEGEN_JAR):$(CUSTOM_CODEGEN_JAR) org.openapitools.codegen.OpenAPIGenerator generate \
	   -i $(SPEC_FILE_NAME) \
	   -g $(GENERATOR) \
	   -o $(OUTPUT_DIR)

generate-and-pub-get: generate
	cd $(OUTPUT_DIR) && flutter pub get