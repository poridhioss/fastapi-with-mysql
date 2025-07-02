# FastAPI CRUD App - Testing Documentation

This document provides comprehensive testing instructions for the FastAPI CRUD App with minimal schema. Each test includes the exact curl command and expected output for verification.

## Prerequisites

- FastAPI application running on `http://localhost:8000`
- MySQL database connected and configured
- `curl` and `jq` installed for testing

## API Endpoints Overview

- **Root**: `GET /`
- **Health Check**: `GET /health`
- **List Users**: `GET /users/`
- **Get User by ID**: `GET /users/{user_id}`
- **Create User**: `POST /users/`
- **Update User**: `PUT /users/{user_id}`
- **Delete User**: `DELETE /users/{user_id}`

## Test Cases

### 1. Root Endpoint

**Purpose**: Verify the application is running and get basic information.

**Command**:
```bash
curl -X GET http://localhost:8000/
```

**Expected Output**:
```json
{
  "message": "FastAPI CRUD App – minimal schema",
  "docs": "/docs",
  "health": "/health"
}
```

**Verification**: Should return basic app information with links to documentation and health endpoints.

### 2. Health Check

**Purpose**: Verify the application and database are running correctly.

**Command**:
```bash
curl -X GET http://localhost:8000/health | jq .
```

**Expected Output**:
```json
{
  "timestamp": "2025-07-02T16:57:56.015977",
  "app": {
    "status": "healthy",
    "message": "FastAPI is running"
  },
  "database": {
    "status": "healthy",
    "message": "Database connection is working",
    "type": "MySQL"
  },
  "overall_status": "healthy"
}
```

**Verification**: All status fields should show "healthy" and timestamp should be current.

### 3. List Users (Empty Database)

**Purpose**: Verify empty user list when no users exist.

**Command**:
```bash
curl -X GET "http://localhost:8000/users/?skip=0&limit=100" | jq .
```

**Expected Output**:
```json
[]
```

**Verification**: Should return an empty array.

### 4. Get Non-Existent User

**Purpose**: Test behavior when requesting a user that doesn't exist.

**Command**:
```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "detail": "User not found"
}
```

**Verification**: Should return a 404 error with "User not found" message.

### 5. Create User (Minimal Schema)

**Purpose**: Create a new user with minimal required fields.

**Command**:
```bash
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name":"Alice"}' | jq .
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice"
}
```

**Verification**: 
- User should receive an auto-generated ID (typically 1 for first user)
- Only name field is required and returned
- No email, timestamps, or other fields in this minimal schema

### 6. Update User

**Purpose**: Update an existing user's information.

**Command**:
```bash
curl -X PUT http://localhost:8000/users/1 \
     -H "Content-Type: application/json" \
     -d '{"name":"Alice Updated"}' | jq .
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice Updated"
}
```

**Verification**: 
- Name should be updated to "Alice Updated"
- ID should remain the same
- Response contains only id and name fields

### 7. Verify Update

**Purpose**: Confirm the update was persisted by retrieving the user again.

**Command**:
```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice Updated"
}
```

**Verification**: Updated name should be persisted in the database.

### 8. Delete User

**Purpose**: Remove a user from the system.

**Command**:
```bash
curl -X DELETE http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```
(No output - empty response)
```

**Verification**: 
- Should return empty response body
- HTTP status should be 200 or 204
- No JSON output expected

### 9. Verify Deletion

**Purpose**: Confirm the user was deleted by attempting to retrieve it.

**Command**:
```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "detail": "User not found"
}
```

**Verification**: Should return a 404 error with "User not found" message.

## Complete Test Sequence

Run all tests in sequence to verify full CRUD functionality:

```bash
# 1. Check root endpoint
curl -X GET http://localhost:8000/

# 2. Health check
curl -X GET http://localhost:8000/health | jq .

# 3. List empty users
curl -X GET "http://localhost:8000/users/?skip=0&limit=100" | jq .

# 4. Try to get non-existent user
curl -X GET http://localhost:8000/users/1 | jq .

# 5. Create user
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name":"Alice"}' | jq .

# 6. Update user
curl -X PUT http://localhost:8000/users/1 \
     -H "Content-Type: application/json" \
     -d '{"name":"Alice Updated"}' | jq .

# 7. Verify update
curl -X GET http://localhost:8000/users/1 | jq .

# 8. Delete user
curl -X DELETE http://localhost:8000/users/1 | jq .

# 9. Verify deletion
curl -X GET http://localhost:8000/users/1 | jq .
```

## Additional Test Cases

### Test Different User Names

**Command**:
```bash
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name":"Bob Smith"}' | jq .
```

**Expected Output**:
```json
{
  "id": 2,
  "name": "Bob Smith"
}
```

### Test List Users with Data

After creating users, test listing:

**Command**:
```bash
curl -X GET "http://localhost:8000/users/" | jq .
```

**Expected Output** (example with users):
```json
[
  {
    "id": 1,
    "name": "Alice"
  },
  {
    "id": 2,
    "name": "Bob Smith"
  }
]
```

### Test Invalid User ID

**Command**:
```bash
curl -X GET http://localhost:8000/users/999 | jq .
```

**Expected Output**:
```json
{
  "detail": "User not found"
}
```

## Schema Differences

This minimal schema version differs from typical user APIs:

- **No email field** - Only name is required
- **No timestamps** - No created_at or updated_at fields
- **No additional metadata** - Minimal response structure
- **Empty delete response** - DELETE returns no JSON content

## Notes

- All timestamps in health check will vary based on when you run the tests
- User IDs are auto-generated and may vary depending on database state
- This is a minimal schema implementation - only `name` field is used
- DELETE operation returns empty response body (not JSON)
- Ensure the database is clean before running the complete test sequence for consistent results
- The `jq` tool is used for JSON formatting - you can omit `| jq .` if you don't have it installed
