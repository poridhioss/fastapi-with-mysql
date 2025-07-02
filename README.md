# FastAPI Users API - Testing Documentation

This document provides comprehensive testing instructions for the FastAPI Users API with health check functionality. Each test includes the exact curl command and expected output for verification.

## Prerequisites

- FastAPI application running on `http://localhost:8000`
- MySQL database connected and configured
- `curl` and `jq` installed for testing

## API Endpoints Overview

- **Health Check**: `GET /health`
- **List Users**: `GET /users/`
- **Get User by ID**: `GET /users/{user_id}`
- **Create User**: `POST /users/`
- **Update User**: `PUT /users/{user_id}`
- **Delete User**: `DELETE /users/{user_id}`

## Test Cases

### 1. Health Check

**Purpose**: Verify the application and database are running correctly.

**Command**:
```bash
curl -X GET http://localhost:8000/health | jq .
```

**Expected Output**:
```json
{
  "timestamp": "2025-07-02T15:11:01.398225",
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

### 2. List Users (Empty Database)

**Purpose**: Verify empty user list when no users exist.

**Command**:
```bash
curl -X GET "http://localhost:8000/users/" | jq .
```

**Expected Output**:
```json
[]
```

**Verification**: Should return an empty array.

### 3. List Users with Pagination (Empty Database)

**Purpose**: Test pagination parameters with empty database.

**Command**:
```bash
curl -X GET "http://localhost:8000/users/?skip=0&limit=20" | jq .
```

**Expected Output**:
```json
[]
```

**Verification**: Should return an empty array regardless of pagination parameters.

### 4. Create User

**Purpose**: Create a new user in the system.

**Command**:
```bash
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice", "email": "alice@example.com"}'
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com",
  "created_at": "2025-07-02T15:11:36",
  "updated_at": "2025-07-02T15:11:36"
}
```

**Verification**: 
- User should receive an auto-generated ID (typically 1 for first user)
- `created_at` and `updated_at` should be identical
- Name and email should match input

### 5. List Users (After Creating User)

**Purpose**: Verify user appears in the list after creation.

**Command**:
```bash
curl -X GET "http://localhost:8000/users/" | jq .
```

**Expected Output**:
```json
[
  {
    "id": 1,
    "name": "Alice",
    "email": "alice@example.com",
    "created_at": "2025-07-02T15:11:36",
    "updated_at": "2025-07-02T15:11:36"
  }
]
```

**Verification**: Array should contain the created user with all fields populated.

### 6. Get User by ID

**Purpose**: Retrieve a specific user by their ID.

**Command**:
```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com",
  "created_at": "2025-07-02T15:11:36",
  "updated_at": "2025-07-02T15:11:36"
}
```

**Verification**: Should return the exact user data matching the ID requested.

### 7. Update User

**Purpose**: Update an existing user's information.

**Command**:
```bash
curl -X PUT http://localhost:8000/users/1 \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice A.", "email": "alice.a@example.com"}'
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice A.",
  "email": "alice.a@example.com",
  "created_at": "2025-07-02T15:11:36",
  "updated_at": "2025-07-02T15:12:11"
}
```

**Verification**: 
- Name and email should be updated
- `created_at` should remain unchanged
- `updated_at` should be newer than `created_at`
- ID should remain the same

### 8. Verify Update

**Purpose**: Confirm the update was persisted by retrieving the user again.

**Command**:
```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice A.",
  "email": "alice.a@example.com",
  "created_at": "2025-07-02T15:11:36",
  "updated_at": "2025-07-02T15:12:11"
}
```

**Verification**: Updated information should be persisted.

### 9. Delete User

**Purpose**: Remove a user from the system.

**Command**:
```bash
curl -X DELETE http://localhost:8000/users/1
```

**Expected Output**:
```json
{
  "message": "User deleted successfully"
}
```

**Verification**: Should return a success message.

### 10. Verify Deletion

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
# 1. Health check
curl -X GET http://localhost:8000/health | jq .

# 2. List empty users
curl -X GET "http://localhost:8000/users/" | jq .

# 3. Create user
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice", "email": "alice@example.com"}'

# 4. List users (should show created user)
curl -X GET "http://localhost:8000/users/" | jq .

# 5. Get user by ID
curl -X GET http://localhost:8000/users/1 | jq .

# 6. Update user
curl -X PUT http://localhost:8000/users/1 \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice A.", "email": "alice.a@example.com"}'

# 7. Verify update
curl -X GET http://localhost:8000/users/1 | jq .

# 8. Delete user
curl -X DELETE http://localhost:8000/users/1

# 9. Verify deletion
curl -X GET http://localhost:8000/users/1 | jq .
```

## Error Test Cases

### Test Non-Existent User

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

### Test Invalid User Creation

**Command**:
```bash
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name": "", "email": "invalid-email"}'
```

**Expected**: Should return validation errors (specific format depends on your validation rules).

## Notes

- All timestamps will vary based on when you run the tests
- User IDs are auto-generated and may vary depending on database state
- Ensure the database is clean before running the complete test sequence for consistent results
- The `jq` tool is used for JSON formatting - you can omit `| jq .` if you don't have it installed
