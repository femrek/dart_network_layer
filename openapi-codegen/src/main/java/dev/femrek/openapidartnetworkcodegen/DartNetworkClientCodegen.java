package dev.femrek.openapidartnetworkcodegen;

import io.swagger.v3.oas.models.Operation;
import org.openapitools.codegen.*;
import org.openapitools.codegen.languages.AbstractDartCodegen;
import org.openapitools.codegen.model.ModelMap;
import org.openapitools.codegen.model.ModelsMap;
import org.openapitools.codegen.model.OperationMap;
import org.openapitools.codegen.model.OperationsMap;
import org.openapitools.codegen.utils.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.*;

public class DartNetworkClientCodegen extends AbstractDartCodegen {
    private final Logger LOGGER = LoggerFactory.getLogger(DartNetworkClientCodegen.class);

    public static final String SERIALIZATION_LIBRARY_NATIVE = "native_serialization";

    public DartNetworkClientCodegen() {
        super();

        final CliOption serializationLibrary = CliOption.newString(CodegenConstants.SERIALIZATION_LIBRARY,
                "Specify serialization library");
        serializationLibrary.setDefault(SERIALIZATION_LIBRARY_NATIVE);

        embeddedTemplateDir = templateDir = "dart-network";

        final Map<String, String> serializationOptions = new HashMap<>();
        serializationOptions.put(SERIALIZATION_LIBRARY_NATIVE, "Use native serializer, backwards compatible");
        serializationLibrary.setEnum(serializationOptions);
        cliOptions.add(serializationLibrary);

        sourceFolder = "";

        // Map 'file' type to MultipartFileSchema from flutter_network_layer_core
        typeMapping.put("file", "MultipartFileSchema");
        typeMapping.put("File", "MultipartFileSchema");
        typeMapping.put("binary", "MultipartFileSchema");

        // Remove http-related imports, add flutter_network_layer_core
        importMapping.clear();
        importMapping.put("MultipartFileSchema", "package:flutter_network_layer_core/flutter_network_layer_core.dart");
    }

    @Override
    public String getName() {
        return "dart-network";
    }

    @Override
    public void processOpts() {
        super.processOpts();

        // handle library not being set
        if (additionalProperties.get(CodegenConstants.SERIALIZATION_LIBRARY) == null) {
            this.library = SERIALIZATION_LIBRARY_NATIVE;
            LOGGER.debug("Serialization library not set, using default {}", SERIALIZATION_LIBRARY_NATIVE);
        } else {
            this.library = additionalProperties.get(CodegenConstants.SERIALIZATION_LIBRARY).toString();
        }

        this.setSerializationLibrary();

        // Only add essential supporting files — no api_client, api_helper, api_exception, auth
        supportingFiles.add(new SupportingFile("pubspec.mustache", "", "pubspec.yaml"));
        supportingFiles.add(new SupportingFile("analysis_options.mustache", "", "analysis_options.yaml"));
        supportingFiles.add(new SupportingFile("apilib.mustache", libPath, "api.dart"));
        supportingFiles.add(new SupportingFile("gitignore.mustache", "", ".gitignore"));
        supportingFiles.add(new SupportingFile("README.mustache", "", "README.md"));
    }

    /**
     * Place model files under lib/model/
     */
    @Override
    public String modelFileFolder() {
        return outputFolder + File.separator + libPath + "model";
    }

    /**
     * Place API (command) files under lib/command/{tag}/
     */
    @Override
    public String apiFileFolder() {
        // The tag-based subfolder is handled via toApiFilename
        return outputFolder + File.separator + libPath + "command";
    }

    @Override
    public String toApiFilename(String name) {
        return StringUtils.underscore(name);
    }

    @Override
    public String toModelFilename(String name) {
        return StringUtils.underscore(name);
    }

    /**
     * Override to produce relative import paths for model files.
     * Since model files are in the same directory, we use just the filename.
     */
    @Override
    public String toModelImport(String name) {
        return StringUtils.underscore(name);
    }

    @Override
    public ModelsMap postProcessModels(ModelsMap objs) {
        objs = super.postProcessModels(objs);

        // Transform model imports from PascalCase class names to snake_case file names
        List<ModelMap> models = objs.getModels();
        for (ModelMap modelMap : models) {
            CodegenModel model = modelMap.getModel();
            // The imports set contains class names like "OwnerSummary", "PetStatus"
            // We need to convert them to snake_case file names for relative imports
            Set<String> newImports = new LinkedHashSet<>();
            for (String imp : model.imports) {
                newImports.add(StringUtils.underscore(imp));
            }
            model.imports.clear();
            model.imports.addAll(newImports);
        }

        return objs;
    }

    @Override
    public OperationsMap postProcessOperationsWithModels(OperationsMap objs, List<ModelMap> allModels) {
        objs = super.postProcessOperationsWithModels(objs, allModels);

        OperationMap operations = objs.getOperations();
        if (operations != null) {
            List<CodegenOperation> ops = operations.getOperation();

            // Collect unique model file imports across all operations in this tag group
            Set<String> uniqueModelImports = new LinkedHashSet<>();

            for (CodegenOperation op : ops) {
                // Add custom vendor extensions for use in mustache templates

                // Snake_case operation id for file naming
                String opIdSnake = StringUtils.underscore(op.operationId);
                op.vendorExtensions.put("x-operation-id-snake", opIdSnake);

                // PascalCase operation id for class naming (e.g. ListPetsCommand)
                String opIdPascal = StringUtils.camelize(op.operationId);
                op.vendorExtensions.put("x-operation-id-pascal", opIdPascal);

                // Determine the return schema name
                if (op.returnType != null && !op.returnType.isEmpty()) {
                    if (op.returnType.equals("Object")) {
                        // Untyped object response — use AnyDataSchema
                        op.vendorExtensions.put("x-has-return-type", false);
                        op.vendorExtensions.put("x-return-schema-name", "AnyDataSchema");
                    } else if (op.returnType.startsWith("List<")) {
                        // For list returns, we need a wrapper Schema
                        op.vendorExtensions.put("x-has-return-type", true);
                        op.vendorExtensions.put("x-is-list-return", true);
                        String innerType = op.returnType.substring(5, op.returnType.length() - 1);
                        op.vendorExtensions.put("x-return-base-type", innerType);
                        String innerFile = StringUtils.underscore(innerType);
                        op.vendorExtensions.put("x-return-base-type-file", innerFile);
                        op.vendorExtensions.put("x-return-schema-name", opIdPascal + "ResponseSchema");
                        uniqueModelImports.add(innerFile);
                    } else {
                        op.vendorExtensions.put("x-has-return-type", true);
                        op.vendorExtensions.put("x-is-list-return", false);
                        op.vendorExtensions.put("x-return-base-type", op.returnType);
                        String retFile = StringUtils.underscore(op.returnType);
                        op.vendorExtensions.put("x-return-base-type-file", retFile);
                        op.vendorExtensions.put("x-return-schema-name", op.returnType);
                        uniqueModelImports.add(retFile);
                    }
                } else {
                    // Void / no-content response — use IgnoredSchema
                    op.vendorExtensions.put("x-has-return-type", false);
                    op.vendorExtensions.put("x-return-schema-name", "IgnoredSchema");
                }

                // Snake_case body param type for import path
                if (op.bodyParam != null) {
                    String bodyDataType = op.bodyParam.dataType;

                    // Handle List<...> body params: extract inner type for import,
                    // and mark with vendor extension so the template can serialize properly
                    if (bodyDataType.startsWith("List<")) {
                        String innerType = bodyDataType.substring(5, bodyDataType.length() - 1);
                        String innerFile = StringUtils.underscore(innerType);
                        op.vendorExtensions.put("x-body-type-file", innerFile);
                        op.vendorExtensions.put("x-is-body-list", true);
                        uniqueModelImports.add(innerFile);
                    } else {
                        String bodyFile = StringUtils.underscore(bodyDataType);
                        op.vendorExtensions.put("x-body-type-file", bodyFile);
                        op.vendorExtensions.put("x-is-body-list", false);
                        uniqueModelImports.add(bodyFile);
                    }
                }

                // Collect imports for all parameter types that reference models (e.g., enums used as query params)
                Set<String> dartPrimitives = Set.of("String", "int", "double", "bool", "num", "DateTime", "Object", "dynamic");
                for (CodegenParameter param : op.allParams) {
                    if (param.isBodyParam || param.isFormParam) continue;
                    String dt = param.dataType;
                    if (dt != null && !dartPrimitives.contains(dt) && !dt.startsWith("List<") && !dt.startsWith("Map<")) {
                        String paramTypeFile = StringUtils.underscore(dt);
                        uniqueModelImports.add(paramTypeFile);
                    }
                }

                // Determine HTTP method enum value
                String methodLower = op.httpMethod.toLowerCase(Locale.ROOT);
                op.vendorExtensions.put("x-http-method-enum", methodLower);

                // Check if operation has a JSON body
                boolean hasJsonBody = op.bodyParam != null && !op.isMultipart;
                op.vendorExtensions.put("x-has-json-body", hasJsonBody);

                // Check if operation has multipart form data
                op.vendorExtensions.put("x-is-multipart", op.isMultipart);

                // Check if operation has query params
                op.vendorExtensions.put("x-has-query-params", op.queryParams != null && !op.queryParams.isEmpty());

                // Check if operation has header params
                op.vendorExtensions.put("x-has-header-params", op.headerParams != null && !op.headerParams.isEmpty());

                // Check if operation has path params
                op.vendorExtensions.put("x-has-path-params", op.pathParams != null && !op.pathParams.isEmpty());

                // Tag name for folder organization
                if (op.tags != null && !op.tags.isEmpty()) {
                    String tagName = StringUtils.underscore(op.tags.getFirst().getName());
                    op.vendorExtensions.put("x-tag-folder", tagName);
                }
            }

            // Store unique imports as a list of maps (mustache can iterate over list of maps)
            List<Map<String, String>> importsList = new ArrayList<>();
            for (String imp : uniqueModelImports) {
                Map<String, String> entry = new HashMap<>();
                entry.put("file", imp);
                importsList.add(entry);
            }
            objs.put("x-unique-model-imports", importsList);
        }

        return objs;
    }

    @Override
    public void addOperationToGroup(String tag, String resourcePath, Operation operation,
                                     CodegenOperation co, Map<String, List<CodegenOperation>> operations) {
        // Group operations by tag (default behavior) — each tag generates one file
        // containing multiple RequestCommand classes
        super.addOperationToGroup(tag, resourcePath, operation, co, operations);
    }

    private void setSerializationLibrary() {
        final String serialization_library = getLibrary();
        LOGGER.info("Using serialization library {}", serialization_library);

        // fall through to default backwards compatible generator
        additionalProperties.put(SERIALIZATION_LIBRARY_NATIVE, "true");
    }
}
