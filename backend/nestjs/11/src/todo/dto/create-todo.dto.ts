import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsDateString,
  IsNumber,
  Min,
  MaxLength,
  IsEnum,
  IsBoolean,
} from 'class-validator';
import { Transform } from 'class-transformer';

export enum TodoPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent',
}

export class CreateTodoDto {
  @ApiProperty({
    description: 'The title of the todo',
    example: 'Complete project documentation',
    maxLength: 255,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  title: string;

  @ApiProperty({
    description: 'The detailed description of the todo',
    example: 'Write comprehensive documentation for the todo application including API docs and user guide',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'The due date for the todo (YYYY-MM-DD format)',
    example: '2025-09-25',
  })
  @IsDateString()
  @IsNotEmpty()
  date: string;

  @ApiProperty({
    description: 'Estimated hours to complete the todo',
    example: 4.5,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  @Transform(({ value }) => parseFloat(value))
  hours: number;

  @ApiProperty({
    description: 'Priority level of the todo',
    example: 'medium',
    enum: TodoPriority,
    default: TodoPriority.MEDIUM,
    required: false,
  })
  @IsEnum(TodoPriority)
  @IsOptional()
  priority?: TodoPriority = TodoPriority.MEDIUM;

  @ApiProperty({
    description: 'Category or tag for the todo',
    example: 'work',
    required: false,
    maxLength: 100,
  })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  category?: string;
}