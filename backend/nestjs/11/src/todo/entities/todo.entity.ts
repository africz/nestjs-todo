import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity('todos')
export class Todo {
  @ApiProperty({
    description: 'The unique identifier of the todo',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ApiProperty({
    description: 'The title of the todo',
    example: 'Complete project documentation',
    maxLength: 255,
  })
  @Column({ length: 255 })
  title: string;

  @ApiProperty({
    description: 'The detailed description of the todo',
    example: 'Write comprehensive documentation for the todo application including API docs and user guide',
    required: false,
  })
  @Column({ type: 'text', nullable: true })
  description: string;

  @ApiProperty({
    description: 'The due date for the todo',
    example: '2025-09-25',
  })
  @Column({ type: 'date' })
  date: string;

  @ApiProperty({
    description: 'Estimated hours to complete the todo',
    example: 4.5,
    minimum: 0,
  })
  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  hours: number;

  @ApiProperty({
    description: 'Whether the todo is completed',
    example: false,
    default: false,
  })
  @Column({ default: false })
  done: boolean;

  @ApiProperty({
    description: 'Priority level of the todo',
    example: 'medium',
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium',
  })
  @Column({
    type: 'enum',
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium',
  })
  priority: string;

  @ApiProperty({
    description: 'Category or tag for the todo',
    example: 'work',
    required: false,
    maxLength: 100,
  })
  @Column({ length: 100, nullable: true })
  category: string;

  @ApiProperty({
    description: 'When the todo was created',
    example: '2025-09-22T10:30:00.000Z',
  })
  @CreateDateColumn()
  createdAt: Date;

  @ApiProperty({
    description: 'When the todo was last updated',
    example: '2025-09-22T14:45:00.000Z',
  })
  @UpdateDateColumn()
  updatedAt: Date;

  @ApiProperty({
    description: 'When the todo was completed (if done)',
    example: '2025-09-22T16:20:00.000Z',
    required: false,
  })
  @Column({ type: 'datetime', nullable: true })
  completedAt: Date;
}