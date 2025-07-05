# Building FastAPI Application with MySQL

## Project Overview

The goal of this project is to build a FastAPI-based CRUD (Create, Read, Update, Delete) operations application with MySQL database integration. The application includes a health check API endpoint to monitor whether FastAPI is running properly and the database connection is working correctly.

This document provides comprehensive testing instructions for the FastAPI Users API with health check functionality. Testing has been performed using both command-line tools (curl) and GUI-based testing (Postman). Each test includes exact `curl` commands, expected outputs, and step-by-step Postman instructions.

## Prerequisites

Before starting this project, ensure you have the following installed on your system:

- **Python 3.8+** - For building the FastAPI application
- **Docker** - For containerizing the FastAPI application
- **Docker Compose** - For orchestrating FastAPI and MySQL services integration
- **curl and jq** - For command-line API testing (jq is optional for JSON formatting)
- **[Postman](https://www.postman.com/)** - For GUI-based API testing
- **Git** - For cloning the repository
- **Text Editor/IDE** - For code development (VS Code, PyCharm, etc.)

**What we'll build:**
1. FastAPI application with CRUD operations
2. Dockerize the FastAPI application
3. Use Docker Compose to integrate FastAPI with MySQL database
4. Implement health check endpoints
5. Test the complete application using curl and Postman

## Project Structure

```
fastapi-with-mysql/
├── main.py              # FastAPI application with CRUD operations
├── requirements.txt     # Python dependencies
├── Dockerfile          # Container configuration for FastAPI app
├── docker-compose.yml  # Orchestration for FastAPI + MySQL
└── init.sql           # Database initialization script
```

## System Architecture

### How It Works

The system consists of the following components:

- **FastAPI Application**: Provides REST API endpoints with CRUD operations for user management
- **SQLAlchemy ORM**: Enables interaction with MySQL using Python objects (no raw SQL needed)
- **Pydantic Models**: Handles input/output data validation and documentation
- **MySQL Database**: Stores user data with proper indexing
- **Docker Containers**: Isolates and manages both services

**Docker Compose Architecture:**
- `app` service: FastAPI application running on port 8000
- `db` service: MySQL 8.0 database with persistent storage
- **Communication**: Services communicate through Docker's internal network

## Application Components

### 1. FastAPI Application (`main.py`)

**Key Features:**
- CRUD operations for user management
- Health check endpoint for monitoring
- Error handling with proper HTTP status codes
- SQLAlchemy ORM integration
- Pydantic models for data validation

**Database Models:**
- `User`: SQLAlchemy model with id, name, email, created_at, updated_at
- Automatic timestamps for creation and updates
- Email uniqueness constraint
- Proper indexing for performance

**API Models:**
- `UserCreate`: For creating new users
- `UserUpdate`: For updating existing users (optional fields)
- `UserResponse`: For API responses

### 2. Database Setup (`init.sql`)

Creates the users table with:
- Auto-incrementing primary key
- Name and email fields with constraints
- Automatic timestamps
- Indexes for performance optimization

### 3. Dependencies (`requirements.txt`)

- `fastapi==0.104.1`: Web framework
- `uvicorn==0.24.0`: ASGI server
- `sqlalchemy==2.0.23`: ORM
- `pymysql==1.1.0`: MySQL driver
- `cryptography==41.0.7`: Security dependencies

### 4. Containerization (`Dockerfile`)

```dockerfile
FROM python:3.11-slim
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy and install requirements
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application code
COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 5. Service Orchestration (`docker-compose.yml`)

- **FastAPI Service**: Builds from Dockerfile, exposes port 8000
- **MySQL Service**: Uses official MySQL 8.0 image
- **Environment Variables**: Database connection configuration
- **Volumes**: Persistent MySQL data storage
- **Dependencies**: Ensures database starts before application

## Setup Instructions

### 1. Clone and Setup

```bash
git clone <repository-url>
cd fastapi-with-mysql
```

### 2. Build and Start Services

```bash
docker-compose up --build
```

This command:
- Builds the FastAPI application container
- Pulls MySQL 8.0 image
- Creates and starts both services
- Initializes database with `init.sql`
- Sets up persistent volume for MySQL data

### 3. Verify Services

- **FastAPI Application**: `http://localhost:8000`
- **API Documentation**: `http://localhost:8000/docs`
- **Health Check**: `http://localhost:8000/health`

## API Endpoints Overview

| Endpoint | Method | Description | Request Body |
|----------|--------|-------------|-------------|
| `/` | GET | Root endpoint with API info | None |
| `/health` | GET | Health check (API & DB) | None |
| `/users/` | GET | List users (with pagination) | None |
| `/users/` | POST | Create new user | `{"name": "string", "email": "string"}` |
| `/users/{user_id}` | GET | Get user by ID | None |
| `/users/{user_id}` | PUT | Update user by ID | `{"name": "string", "email": "string"}` |
| `/users/{user_id}` | DELETE | Delete user by ID | None |

## Testing with curl

### 1. Health Check

**Purpose**: Verify application and database connectivity.

```bash
curl -X GET http://localhost:8000/health | jq .
```

**Expected Output**:
```json
{
  "timestamp": "2025-07-05T15:11:01.398225",
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

**Verification**: All status fields should show "healthy" with current timestamp.

### 2. Root Endpoint

```bash
curl -X GET http://localhost:8000/ | jq .
```

**Expected Output**:
```json
{
  "message": "FastAPI CRUD App",
  "docs": "/docs",
  "health": "/health"
}
```

### 3. List Users (Empty Database)

**Purpose**: Verify empty user list when no users exist.

```bash
curl -X GET "http://localhost:8000/users/" | jq .
```

**Expected Output**:
```json
[]
```

### 4. List Users with Pagination

**Purpose**: Test pagination parameters with empty database.

```bash
curl -X GET "http://localhost:8000/users/?skip=0&limit=20" | jq .
```

**Expected Output**:
```json
[]
```

### 5. Create User

**Purpose**: Create a new user in the system.

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
  "created_at": "2025-07-05T15:11:36.123456",
  "updated_at": "2025-07-05T15:11:36.123456"
}
```

**Verification**:
- Auto-generated ID (typically 1 for first user)
- Identical `created_at` and `updated_at` timestamps
- Name and email match input

### 6. Create Duplicate User (Error Test)

**Purpose**: Test email uniqueness constraint.

```bash
curl -X POST http://localhost:8000/users/ \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice Again", "email": "alice@example.com"}'
```

**Expected Output**:
```json
{
  "detail": "Email already registered"
}
```

### 7. List Users (After Creation)

**Purpose**: Verify user appears in list after creation.

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
    "created_at": "2025-07-05T15:11:36.123456",
    "updated_at": "2025-07-05T15:11:36.123456"
  }
]
```

### 8. Get User by ID

**Purpose**: Retrieve specific user by ID.

```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com",
  "created_at": "2025-07-05T15:11:36.123456",
  "updated_at": "2025-07-05T15:11:36.123456"
}
```

### 9. Get Non-existent User (Error Test)

```bash
curl -X GET http://localhost:8000/users/999 | jq .
```

**Expected Output**:
```json
{
  "detail": "User not found"
}
```

### 10. Update User

**Purpose**: Update existing user information.

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
  "created_at": "2025-07-05T15:11:36.123456",
  "updated_at": "2025-07-05T15:12:11.789012"
}
```

**Verification**:
- Updated name and email
- Unchanged `created_at`
- Newer `updated_at` timestamp
- Same ID

### 11. Partial Update

**Purpose**: Update only specific fields.

```bash
curl -X PUT http://localhost:8000/users/1 \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice Updated"}'
```

### 12. Delete User

**Purpose**: Remove user from system.

```bash
curl -X DELETE http://localhost:8000/users/1
```

**Expected Output**:
```json
{
  "message": "User deleted successfully"
}
```

### 13. Verify Deletion

**Purpose**: Confirm user deletion.

```bash
curl -X GET http://localhost:8000/users/1 | jq .
```

**Expected Output**:
```json
{
  "detail": "User not found"
}
```

## Testing with Postman

### Setup
1. Open Postman
2. Create new collection called "FastAPI Users API"
3. Add requests for each endpoint

### Health Check
- **Method**: GET
- **URL**: `http://localhost:8000/health`

### Root Endpoint
- **Method**: GET
- **URL**: `http://localhost:8000/`

### List Users
- **Method**: GET
- **URL**: `http://localhost:8000/users/`
- **Optional Query Parameters**: `skip=0&limit=10`

### Create User
- **Method**: POST
- **URL**: `http://localhost:8000/users/`
- **Headers**: `Content-Type: application/json`
- **Body** (raw, JSON):
```json
{
  "name": "Alice",
  "email": "alice@example.com"
}
```

### Get User by ID
- **Method**: GET
- **URL**: `http://localhost:8000/users/1`

### Update User
- **Method**: PUT
- **URL**: `http://localhost:8000/users/1`
- **Headers**: `Content-Type: application/json`
- **Body** (raw, JSON):
```json
{
  "name": "Alice A.",
  "email": "alice.a@example.com"
}
```

### Delete User
- **Method**: DELETE
- **URL**: `http://localhost:8000/users/1`

## Database Inspection

### 1. Access MySQL Container

Find the container name:
```bash
docker ps
```

Enter the MySQL container:
```bash
docker exec -it <mysql-container-name> mysql -u user -p
```

When prompted, enter password: `password`

### 2. MySQL Commands

Switch to database:
```sql
USE fastapi_db;
```

**Common Operations**:
```sql
-- Show all tables
SHOW TABLES;

-- Describe table structure
DESCRIBE users;

-- View all users
SELECT * FROM users;

-- Insert test user
INSERT INTO users (name, email) VALUES ('Test User', 'test@example.com');

-- Delete user
DELETE FROM users WHERE id=1;

-- Check table indexes
SHOW INDEX FROM users;
```

### 3. Exit MySQL
```bash
exit
```

## Swagger UI Documentation

Access the built-in API documentation at `http://localhost:8000/docs`

**Features**:
- Interactive API documentation
- Test API requests directly from browser
- View request/response schemas
- Try out all endpoints with sample data
- Built-in authentication testing (if implemented)

## Error Handling

The API provides comprehensive error handling:

### Client Errors (4xx)
- **400 Bad Request**: Email already registered, validation errors
- **404 Not Found**: User not found
- **422 Unprocessable Entity**: Invalid request body

### Server Errors (5xx)
- **503 Service Unavailable**: Database connection issues

### Error Response Format
```json
{
  "detail": "Error message description"
}
```

## Environment Configuration

### Database Connection
The application uses environment variables for database configuration:

```bash
DATABASE_URL=mysql+pymysql://user:password@db:3306/fastapi_db
```

### Docker Environment Variables
- `MYSQL_ROOT_PASSWORD`: Root password for MySQL
- `MYSQL_DATABASE`: Database name
- `MYSQL_USER`: Application database user
- `MYSQL_PASSWORD`: Application database password

## Troubleshooting

### Connection Issues
**Problem**: Can't connect to API

**Solutions**:
- Check container status: `docker ps`
- View logs: `docker-compose logs`
- Restart services: `docker-compose restart`

### Database Errors
**Problem**: Database connection issues

**Solutions**:
- Check MySQL container logs: `docker-compose logs db`
- Verify database initialization: Check if `init.sql` executed properly
- Connect to MySQL directly to inspect tables/data
- Ensure proper environment variables in docker-compose.yml

### Code Changes Not Showing
**Problem**: Updates not reflected

**Solution**:
```bash
docker-compose down
docker-compose up --build
```

### Port Conflicts
**Problem**: Port 8000 already in use

**Solutions**:
- Change port mapping in docker-compose.yml: `"8001:8000"`
- Stop conflicting services: `sudo lsof -i :8000`

### MySQL Connection Errors
**Problem**: Can't connect to MySQL

**Common Solutions**:
- Wait for MySQL to fully initialize (can take 30-60 seconds on first run)
- Check MySQL logs for initialization errors
- Verify credentials in docker-compose.yml match application configuration

## Development Tips

1. **View Real-time Logs**:
   ```bash
   docker-compose logs -f app
   docker-compose logs -f db
   ```

2. **Rebuild After Code Changes**:
   ```bash
   docker-compose up --build app
   ```

3. **Connect to Running Container**:
   ```bash
   docker exec -it <container-name> /bin/bash
   ```

4. **Database Backup**:
   ```bash
   docker exec <mysql-container> mysqldump -u user -p fastapi_db > backup.sql
   ```

## Notes

- All timestamps are in UTC format
- User IDs are auto-generated and may vary depending on database state
- Email addresses must be unique across all users
- The `jq` tool is used for JSON formatting (optional - can be omitted if not installed)
- MySQL data persists between container restarts due to volume mapping
- API automatically generates OpenAPI documentation available at `/docs` and `/redoc`