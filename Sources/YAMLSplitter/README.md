# YAMLSplitter

A Swift package for splitting a single OpenAPI YAML file into organized schema files - the opposite of YAMLMerger.

## How It Works

YAMLSplitter takes a single OpenAPI YAML file and splits it into organized schema files following the same structure as YAMLMerger:

1. **01_Info/** - OpenAPI info section (version, title, description, etc.)
2. **02_Servers/** - API server URLs and environment configurations  
3. **03_Tags/** - Tag definitions for organizing endpoints
4. **04_Paths/** - API endpoint definitions (one file per path)
5. **06_Components/** - Reusable components (one file per schema)
6. **07_Security/** - Security requirements
7. **08_ExternalDocs/** - External documentation references

## Usage

```swift
import YAMLSplitter

// Split a single OpenAPI YAML into organized schema files
let splitter = YAMLSplitter(
    inputFile: URL(fileURLWithPath: "openapi.yaml"),
    outputDirectory: URL(fileURLWithPath: "Schema")
)

try splitter.split()
```

## Directory Structure Created

```
Schema/
├── 01_Info/
│   ├── __info.yaml          # Header file
│   └── api-info.yaml        # Info content
├── 02_Servers/
│   ├── __servers.yaml       # Header file
│   └── server-1.yaml        # Individual server configs
├── 03_Tags/
│   ├── __tags.yaml          # Header file
│   └── tags.yaml            # Tag definitions
├── 04_Paths/
│   ├── __paths.yaml         # Header file
│   ├── api_login.yaml
│   ├── api_buser.yaml
│   └── ... (one file per path)
├── 06_Components/
│   ├── __components.yaml    # Header file
│   ├── Login.yaml
│   ├── User.yaml
│   └── ... (one file per schema)
├── 07_Security/
│   ├── __securitySchemes.yaml
│   └── security.yaml
└── 08_ExternalDocs/
    ├── __externalDocs.yaml
    └── externalDocs.yaml
```

## Round Trip Testing

YAMLSplitter works perfectly with YAMLMerger for round-trip testing:

```swift
// 1. Split the original openapi.yaml
let splitter = YAMLSplitter(inputFile: originalFile, outputDirectory: schemaDir)
try splitter.split()

// 2. Merge back using YAMLMerger
let merger = YAMLMerger(rootDirectory: schemaDir, outputFileName: "CombinedSpec.yaml")
merger.merge()

// 3. The result should be identical to the original
```

## Key Features

- ✅ **Organized Structure** - Follows the same directory structure as YAMLMerger
- ✅ **One File Per Component** - Each path and schema gets its own file
- ✅ **Header Files** - Creates `__*.yaml` header files for proper merging
- ✅ **Round Trip Compatible** - Works perfectly with YAMLMerger
- ✅ **YAML Parsing** - Uses Yams library for robust YAML handling
- ✅ **Error Handling** - Comprehensive error handling and validation

## Dependencies

- **Yams** - Swift YAML library for parsing and generating YAML

## Testing

The package includes comprehensive tests that:

1. Split the ApiShared/openapi.yaml into organized schema files
2. Verify all expected directories and files are created
3. Test round-trip compatibility with YAMLMerger
4. Validate the structure matches YAMLMerger expectations

## Use Cases

- **API Documentation** - Split large OpenAPI specs into manageable files
- **Team Collaboration** - Allow different team members to work on different sections
- **Version Control** - Better diff tracking for specific components
- **Modular Development** - Work on individual endpoints and schemas separately
- **Round Trip Testing** - Validate that split + merge produces identical results
