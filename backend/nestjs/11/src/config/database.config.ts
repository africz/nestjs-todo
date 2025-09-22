import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { Todo } from '../todo/entities/todo.entity';

export const databaseConfig: TypeOrmModuleOptions = {
  type: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 3306,
  username: process.env.DB_USERNAME || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_DATABASE || 'todoapp',
  entities: [Todo],
  synchronize: process.env.NODE_ENV !== 'production', // Auto-create tables in development
  logging: process.env.NODE_ENV === 'development',
  timezone: 'UTC',
  charset: 'utf8mb4',
};