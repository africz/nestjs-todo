import { PartialType } from '@nestjs/swagger';
import { CreateTodoDto } from './create-todo.dto';
import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsDate } from 'class-validator';

export class UpdateTodoDto extends PartialType(CreateTodoDto) {
  @ApiProperty({
    description: 'Whether the todo is completed',
    example: false,
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  done?: boolean;

  @ApiProperty({
    description: 'When the todo was completed',
    example: '2025-09-22T16:20:00.000Z',
    required: false,
  })
  @IsDate()
  @IsOptional()
  completedAt?: Date;
}