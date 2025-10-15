# YAMLMerger

A Swift package for merging multiple YAML files from subdirectories into a single combined file.

## How It Works

YAMLMerger recursively scans subdirectories for YAML files and merges them in a predictable order:

1. Folders are processed in numerical order (01 → 02 → 03 → ...)
2. Within each folder, `__*.yaml` files are merged first (due to `__` prefix)
3. All additional YAML files are then merged in alphabetical order
4. The result is a single, properly structured OpenAPI specification file

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
OpenAPI metadata and general information.

```yaml
# __info.yaml (header file)
openapi: 3.0.0
info:

# api-info.yaml
  title: OpenAPI Generation Demo
  version: 1.0.0
  description: Demonstration of OpenAPI specification generation using YAMLMerger
```

#### 02_Servers/
API server URLs and configurations.

```yaml
# dummyjson-server.yaml
  - url: https://dummyjson.com
    description: DummyJSON API Server

# local-server.yaml
  - url: http://localhost:8080
    description: Local development server
```

#### 03_Tags/
Tag definitions for organizing endpoints.

```yaml
# tags.yaml
  - name: auth
    description: Authentication operations
  - name: users
    description: User management operations
  - name: posts
    description: Post management operations
  - name: products
    description: Product catalog operations
```

#### 04_Paths/
API endpoint definitions (one file per resource).

```yaml
# auth.yaml
  /auth/login:
    post:
      operationId: loginUser
      tags: [auth]
      summary: User login
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LoginRequest'
      responses:
        '200':
          description: Successful authentication

# users.yaml
  /users:
    get:
      operationId: getAllUsers
      tags: [users]
      summary: Get all users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 30
      responses:
        '200':
          description: Successful response
    post:
      operationId: createUser
      tags: [users]
      summary: Add a new user
      security:
        - bearerAuth: []
      responses:
        '201':
          description: User created successfully
```

**Try it:**
```bash
# Auth - Login
curl -X POST https://dummyjson.com/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username": "emilys", "password": "emilyspass"}'

# Users - Get all
curl https://dummyjson.com/users?limit=5

# Users - Get single
curl https://dummyjson.com/users/1

# Posts - Get all
curl https://dummyjson.com/posts?limit=5

# Posts - Get single
curl https://dummyjson.com/posts/1

# Products - Get all
curl https://dummyjson.com/products?limit=5

# Products - Get single
curl https://dummyjson.com/products/1

# Carts - Get all
curl https://dummyjson.com/carts?limit=5

# Carts - Get single
curl https://dummyjson.com/carts/1

# Todos - Get all
curl https://dummyjson.com/todos?limit=5

# Todos - Get single
curl https://dummyjson.com/todos/1

# Comments - Get all
curl https://dummyjson.com/comments?limit=5

# Comments - Get single
curl https://dummyjson.com/comments/1
```

#### 05_Webhooks/
Webhook/callback definitions (OpenAPI 3.1+).

```yaml
# new-comment.yaml
  newComment:
    post:
      operationId: onNewComment
      summary: New comment notification
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                event:
                  type: string
                  example: comment.created
                timestamp:
                  type: string
                  format: date-time
                data:
                  $ref: '#/components/schemas/Comment'

# new-post.yaml
  newPost:
    post:
      operationId: onNewPost
      summary: New post notification
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                event:
                  type: string
                  example: post.published
                data:
                  $ref: '#/components/schemas/Post'
```

**Test webhook receiver:**
```bash
# Start a local webhook receiver (requires nc)
nc -l 8080

# In another terminal, simulate a webhook POST
curl -X POST http://localhost:8080/webhook \
  -H 'Content-Type: application/json' \
  -d '{
    "event": "comment.created",
    "timestamp": "2025-10-15T10:30:00Z",
    "data": {
      "id": 1,
      "body": "Great post!",
      "postId": 1,
      "likes": 5,
      "user": {
        "id": 1,
        "username": "emilys",
        "fullName": "Emily Johnson"
      }
    }
  }'
```

#### 06_Components/
Reusable schema definitions (one per file).

```yaml
# LoginRequest.yaml
      LoginRequest:
        type: object
        required: [username, password]
        properties:
          username:
            type: string
          password:
            type: string
            format: password

# User.yaml
      User:
        type: object
        properties:
          id:
            type: integer
          firstName:
            type: string
          lastName:
            type: string
          email:
            type: string
            format: email

# Post.yaml
      Post:
        type: object
        properties:
          id:
            type: integer
          title:
            type: string
          body:
            type: string
          userId:
            type: integer
```


#### 07_Security/
Security schemes and requirements.

```yaml
# bearer-auth.yaml
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token obtained from /auth/login endpoint
```

**Try it:**
```bash
# Get token
TOKEN=$(curl -s -X POST https://dummyjson.com/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username": "emilys", "password": "emilyspass"}' \
  | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

# Use token to get authenticated user
curl https://dummyjson.com/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

#### 08_ExternalDocs/
Links to external documentation.

```yaml
# __externalDocs.yaml
externalDocs:
  description: DummyJSON Documentation
  url: https://dummyjson.com/docs
```

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
