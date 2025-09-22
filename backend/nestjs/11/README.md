# Todo Backend API

A comprehensive NestJS backend API for todo management with MySQL database integration.

## Features

- 🚀 **RESTful API** with full CRUD operations
- 📊 **Statistics & Analytics** for todo tracking
- 🔍 **Advanced Filtering** by status, priority, category, date range, and search
- 📅 **Due Date Management** with overdue detection
- 🏷️ **Priority & Category System** for organization
- 📝 **Comprehensive Validation** with class-validator
- 📚 **API Documentation** with Swagger/OpenAPI
- 🗄️ **MySQL Database** with TypeORM
- 🐳 **Docker Ready** with production configurations

## API Endpoints

### Todo Management
- `POST /api/todos` - Create a new todo
- `GET /api/todos` - Get all todos (with filtering)
- `GET /api/todos/:id` - Get a specific todo
- `PATCH /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo
- `PATCH /api/todos/:id/toggle` - Toggle todo completion

### Analytics & Filtering
- `GET /api/todos/statistics` - Get comprehensive statistics
- `GET /api/todos/overdue` - Get overdue todos
- `GET /api/todos/upcoming?days=7` - Get upcoming todos
- `GET /api/todos/category/:category` - Get todos by category
- `GET /api/todos/priority/:priority` - Get todos by priority

### Query Parameters
- `status` - Filter by completion status (completed/pending)
- `priority` - Filter by priority (low/medium/high/urgent)
- `category` - Filter by category
- `startDate` & `endDate` - Filter by date range (YYYY-MM-DD)
- `search` - Search in title and description

## Data Model

### Todo Entity
```typescript
{
  id: string;           // UUID primary key
  title: string;        // Todo title (required, max 255 chars)
  description: string;  // Detailed description (optional)
  date: string;         // Due date (YYYY-MM-DD format)
  hours: number;        // Estimated hours to complete
  done: boolean;        // Completion status
  priority: string;     // Priority level (low/medium/high/urgent)
  category: string;     // Category/tag (optional)
  createdAt: Date;      // Creation timestamp
  updatedAt: Date;      // Last update timestamp
  completedAt: Date;    // Completion timestamp (when marked done)
}
```

## Getting Started

### Prerequisites
- Node.js 20+ 
- MySQL 8.0+
- npm or yarn

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. **Database setup:**
   ```bash
   # Create database
   mysql -u root -p -e "CREATE DATABASE todoapp;"
   ```

4. **Start development server:**
   ```bash
   npm run start:dev
   ```

### Environment Variables

```env
# Application
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=password
DB_DATABASE=todoapp

# Security
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h

# CORS
CORS_ORIGIN=*
```

## Development

### Available Scripts

```bash
npm run start:dev    # Start development server with hot reload
npm run start:debug  # Start with debugging enabled
npm run build        # Build for production
npm run start:prod   # Start production server
npm run test         # Run unit tests
npm run test:e2e     # Run end-to-end tests
npm run lint         # Run ESLint
npm run format       # Format code with Prettier
```

### API Documentation

Once the server is running, visit:
- **Swagger UI:** http://localhost:3000/api/docs
- **OpenAPI JSON:** http://localhost:3000/api/docs-json

### Database Schema

The application uses TypeORM with automatic schema synchronization in development mode. The todo table will be created automatically with the following structure:

```sql
CREATE TABLE todos (
  id VARCHAR(36) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  hours DECIMAL(10,2) DEFAULT 0,
  done BOOLEAN DEFAULT FALSE,
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  category VARCHAR(100),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  completedAt TIMESTAMP NULL
);
```

## Production Deployment

### Using Docker

The application is Docker-ready with configurations in the `/docker` directory.

```bash
# Build and start with Docker Compose
cd ../../docker
make nestjs-todo-up

# Or manually with docker
docker build -t todo-backend .
docker run -p 3000:3000 --env-file .env todo-backend
```

### Manual Deployment

1. **Build the application:**
   ```bash
   npm run build
   ```

2. **Set production environment:**
   ```bash
   export NODE_ENV=production
   export DB_HOST=your-production-db-host
   # ... other environment variables
   ```

3. **Start the server:**
   ```bash
   npm run start:prod
   ```

## Testing

### Sample API Calls

```bash
# Create a todo
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete documentation",
    "description": "Write comprehensive API documentation",
    "date": "2025-09-25",
    "hours": 4,
    "priority": "high",
    "category": "work"
  }'

# Get all todos
curl http://localhost:3000/api/todos

# Get statistics
curl http://localhost:3000/api/todos/statistics

# Filter todos
curl "http://localhost:3000/api/todos?status=pending&priority=high"

# Toggle completion
curl -X PATCH http://localhost:3000/api/todos/{id}/toggle
```

## Architecture

### Project Structure
```
src/
├── config/           # Configuration files
├── todo/            # Todo module
│   ├── dto/         # Data Transfer Objects
│   ├── entities/    # Database entities
│   ├── todo.controller.ts
│   ├── todo.service.ts
│   └── todo.module.ts
├── app.module.ts    # Main application module
└── main.ts          # Application bootstrap
```

### Key Technologies
- **NestJS** - Progressive Node.js framework
- **TypeORM** - Database ORM with TypeScript support
- **MySQL** - Relational database
- **class-validator** - Validation decorators
- **Swagger** - API documentation
- **Docker** - Containerization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Run `npm run lint` and `npm run test`
6. Submit a pull request

## License

This project is licensed under the MIT License.
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## Description

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
# mt-backend-nestjs-11
# mt-backend-nestjs-11
