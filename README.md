# YAMLMerger

A Swift package for merging multiple YAML files from subdirectories into a single combined file.

## Features

- Recursively scans subdirectories for YAML files (.yaml or .yml extensions)
- Sorts subdirectories and files alphabetically
- Merges content in a predictable order
- Outputs a single combined YAML file

## Directory Structure for OpenAPI Schemas

When using YAMLMerger for OpenAPI specifications, organize your YAML files into the following subdirectories:

```
Schema/
├── 01_Info/           # OpenAPI info section (version, title, description, etc.)
├── 02_Servers/        # API server URLs and environment configurations
├── 03_Tags/           # Tag definitions for organizing endpoints
├── 04_Paths/          # API endpoint definitions
├── 05_Webhooks/       # Webhook/callback definitions (OpenAPI 3.1+)
├── 06_Components/     # Reusable components (schemas, responses, parameters, etc.)
├── 07_Security/       # Top-level security requirements
└── 08_ExternalDocs/   # External documentation references
```

Place your distinct YAML files into the corresponding folders:

#### 01_Info/
Add files containing OpenAPI metadata and general information.

Example (`__info.yaml`):
```yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
  description: A comprehensive REST API for managing resources
  contact:
    name: API Support
    email: support@example.com
  license:
    name: Apache 2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html
```

#### 02_Servers/
Add server configuration files (production, staging, development URLs).

Example (`__servers.yaml`):
```yaml
servers:
  - url: https://api.example.com/v1
    description: Production server
  - url: https://staging-api.example.com/v1
    description: Staging server
  - url: http://localhost:8000/v1
    description: Development server
```

#### 03_Tags/
Add tag definitions to organize and group your API endpoints.

Example (`__tags.yaml`):
```yaml
tags:
  - name: users
    description: User management operations
  - name: products
    description: Product catalog operations
  - name: orders
    description: Order processing and management
```

#### 04_Paths/
Add individual endpoint definition files (one per endpoint or grouped logically).

Example (`users.yaml`):
```yaml
  /users:
    get:
      tags:
        - users
      summary: List all users
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
    post:
      tags:
        - users
      summary: Create a new user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserInput'
      responses:
        '201':
          description: User created successfully
```

#### 05_Webhooks/
Add webhook definitions for callbacks your API sends (OpenAPI 3.1+).

Example (`order-events.yaml`):
```yaml
  orderStatusChanged:
    post:
      summary: Order status change notification
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                orderId:
                  type: string
                status:
                  type: string
                timestamp:
                  type: string
                  format: date-time
      responses:
        '200':
          description: Webhook received successfully
```

#### 06_Components/
Add reusable schema definitions, response objects, parameters, security schemes, etc.

Example (`User.yaml`):
```yaml
  User:
    type: object
    required:
      - id
      - email
      - name
    properties:
      id:
        type: string
        format: uuid
      email:
        type: string
        format: email
      name:
        type: string
      createdAt:
        type: string
        format: date-time
```

#### 07_Security/
Add top-level security requirements that apply across the API.

Example (`__securitySchemes.yaml`):
```yaml
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
security:
  - bearerAuth: []
```

#### 08_ExternalDocs/
Add links to external documentation.

Example (`__externalDocs.yaml`):
```yaml
externalDocs:
  description: Find more information in our documentation
  url: https://docs.example.com/api
```

The numeric prefixes ensure subdirectories are processed in the correct order during merging.

### How the Merger Works

Each folder contains a `__*.yaml` file (e.g., `__paths.yaml`, `__components.yaml`) that serves as a section header. Due to the `__` prefix, these files are sorted and merged first within each folder, followed by all other YAML files in alphabetical order. This ensures:

1. Folders are processed in numerical order (01 → 02 → 03 → ...)
2. Within each folder, the section header (`__*.yaml`) is merged first
3. All additional YAML files in the folder are then merged in alphabetical order
4. The result is a single, properly structured OpenAPI specification file

## Usage

```swift
import YAMLMerger

let merger = YAMLMerger(
    rootDirectory: URL(fileURLWithPath: "/path/to/yaml/files"),
    outputFileName: "CombinedSpec.yaml"
)
merger.merge()
```

## Requirements

- Swift 6.1+
- macOS 14.0+ / iOS 17.0+

## Installation

### Swift Package Manager

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/YAMLMerger", from: "1.0.0")
]
```

## License

Add your license here.
