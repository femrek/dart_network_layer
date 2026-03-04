package dev.femrek.openapidartnetworkcodegen;

import org.checkerframework.checker.nullness.qual.NonNull;
import org.openapitools.codegen.ClientOptInput;
import org.openapitools.codegen.DefaultGenerator;
import org.openapitools.codegen.config.CodegenConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.List;

import static org.apache.commons.io.FileUtils.deleteDirectory;

/**
 * Executable to generate actual Dart code from an OpenAPI spec
 */
public class GenerateExample {
    private static final Logger LOGGER = LoggerFactory.getLogger(GenerateExample.class);

    static void main(String[] ignored) {
        System.out.println("=== Generating Dart Clients from OpenAPI Spec ===\n");

        // Get the current directory
        String projectDir = System.getProperty("user.dir");
        String baseOutputDir = projectDir + "/generated-output";
        List<String> specFiles = List.of(
                "example1.yaml",
                "example2.json",
                "api-with-examples.json",
                "callback-example.json",
                "link-example.json",
                "petstore-expanded.json",
                "petstore.json",
                "uspto.json"
        );

        System.out.println("Input Specs: " + specFiles);
        System.out.println("Base Output Directory: " + baseOutputDir);
        System.out.println();

        // remove existing output directory if it exists
        File outputDirToRemove = new File(baseOutputDir);
        if (outputDirToRemove.exists()) {
            try {
                System.out.println("⚠️  Output directory already exists. Deleting: " + baseOutputDir);
                deleteDirectory(outputDirToRemove);
                System.out.println("✅ Old output directory deleted.");
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        for (String inputSpec : specFiles) {
            generateForSpec(
                    projectDir + '/' + "spec_samples" + '/' + inputSpec,
                    baseOutputDir + '/' + inputSpec.substring(0, inputSpec.lastIndexOf('.'))
            );
        }
    }

    private static void generateForSpec(
            String inputSpec,
            String baseOutputDir
    ) {
        // Check if input spec exists
        File specFile = new File(inputSpec);
        if (!specFile.exists()) {
            System.err.println("ERROR: OpenAPI spec file not found at: " + inputSpec);
            System.exit(1);
        }

        // Define the generators to use
        GeneratorConfig[] generatorConfigs = {
//                new GeneratorConfig("dart",         "Standard Dart Client",          "dart-client"),
//                new GeneratorConfig("dart-dio",     "Dart Dio Client",               "dart-dio-client"),
                new GeneratorConfig("dart-network", "Dart Network Client (Custom)",  "dart-network-client"),
        };

        boolean allSuccessful = true;

        // Generate code with each generator
        for (int i = 0; i < generatorConfigs.length; i++) {
            GeneratorConfig config = generatorConfigs[i];
            String generator   = config.generatorName();
            String description = config.description();
            String outputDir   = baseOutputDir + "/" + config.folderName();

            System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
            System.out.println("Generator " + (i + 1) + "/" + generatorConfigs.length + ": " + description);
            System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
            System.out.println("Generator: " + generator);
            System.out.println("Output: " + outputDir);
            System.out.println();

            try {
                // Configure the code generator
                CodegenConfigurator configurator = getCodegenConfigurator(inputSpec, outputDir, generator);

                System.out.println("  ⚙️  Configuring generator...");
                ClientOptInput clientOptInput = configurator.toClientOptInput();

                System.out.println("  🔧 Initializing generator...");
                DefaultGenerator codeGenerator = new DefaultGenerator();

                System.out.println("  🚀 Generating code...");
                codeGenerator.opts(clientOptInput).generate();

                System.out.println("  ✅ Generation completed successfully!");
                System.out.println();

                // List the generated structure
                System.out.println("  📁 Generated Structure:");
                listDirectory(new File(outputDir), 2, 3);
                System.out.println();

            } catch (Exception e) {
                LOGGER.error("ERROR during code generation for generator: {}", generator, e);
                System.err.println("  ❌ Failed to generate code with " + generator);
                System.err.println("  Error: " + e.getMessage());
                System.out.println();
                allSuccessful = false;
            }
        }

        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        if (allSuccessful) {
            System.out.println("✅ All generators completed successfully!");
        } else {
            System.out.println("⚠️  Some generators failed. Check logs above for details.");
        }
        System.out.println("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        System.out.println();
        System.out.println("Generated files are located at: " + baseOutputDir);
        System.out.println();

        if (!allSuccessful) {
            System.exit(1);
        }
    }

    private static @NonNull CodegenConfigurator getCodegenConfigurator(String inputSpec, String outputDir, String generatorName) {
        CodegenConfigurator configurator = new CodegenConfigurator();
        configurator.setGeneratorName(generatorName);
        configurator.setInputSpec(inputSpec);
        configurator.setOutputDir(outputDir);
        configurator.setPackageName("pet_store_api");
        configurator.setApiPackage("api");
        configurator.setModelPackage("model");

        // Add additional properties
        configurator.addAdditionalProperty("pubName", "pet_store_api");
        configurator.addAdditionalProperty("pubVersion", "1.0.0");
        configurator.addAdditionalProperty("pubDescription", "Pet Store API Client generated with " + generatorName);

        return configurator;
    }

    private static void listDirectory(File dir, int level, int maxLevel) {
        if (level > maxLevel || !dir.exists() || !dir.isDirectory()) {
            return;
        }

        File[] files = dir.listFiles();
        if (files == null) return;

        for (File file : files) {
            // Skip hidden files and .openapi-generator directory
            if (file.getName().startsWith(".")) {
                continue;
            }

            String indent = "  ".repeat(level);
            if (file.isDirectory()) {
                System.out.println(indent + "📁 " + file.getName() + "/");
                listDirectory(file, level + 1, maxLevel);
            } else {
                System.out.println(indent + "📄 " + file.getName());
            }
        }
    }

    private record GeneratorConfig(String generatorName, String description, String folderName) {}
}

