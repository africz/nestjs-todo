import { ApiProperty } from '@nestjs/swagger';

export class TodoStatisticsDto {
  @ApiProperty({
    description: 'Total number of todos',
    example: 25,
  })
  total: number;

  @ApiProperty({
    description: 'Number of completed todos',
    example: 15,
  })
  completed: number;

  @ApiProperty({
    description: 'Number of pending todos',
    example: 10,
  })
  pending: number;

  @ApiProperty({
    description: 'Total estimated hours',
    example: 120.5,
  })
  totalHours: number;

  @ApiProperty({
    description: 'Hours from completed todos',
    example: 75.5,
  })
  completedHours: number;

  @ApiProperty({
    description: 'Hours from pending todos',
    example: 45.0,
  })
  pendingHours: number;

  @ApiProperty({
    description: 'Number of overdue todos',
    example: 3,
  })
  overdue: number;

  @ApiProperty({
    description: 'Breakdown by priority',
    example: {
      low: 5,
      medium: 12,
      high: 6,
      urgent: 2,
    },
  })
  byPriority: {
    low: number;
    medium: number;
    high: number;
    urgent: number;
  };

  @ApiProperty({
    description: 'Breakdown by category',
    example: {
      work: 15,
      personal: 8,
      study: 2,
    },
  })
  byCategory: Record<string, number>;
}