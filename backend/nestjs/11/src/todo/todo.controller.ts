import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  ValidationPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiParam,
  ApiBadRequestResponse,
  ApiNotFoundResponse,
} from '@nestjs/swagger';
import { TodoService } from './todo.service';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';
import { TodoStatisticsDto } from './dto/todo-statistics.dto';
import { Todo } from './entities/todo.entity';

@ApiTags('todos')
@Controller('api/todos')
export class TodoController {
  constructor(private readonly todoService: TodoService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new todo' })
  @ApiResponse({
    status: 201,
    description: 'The todo has been successfully created.',
    type: Todo,
  })
  @ApiBadRequestResponse({ description: 'Invalid input data' })
  create(@Body(ValidationPipe) createTodoDto: CreateTodoDto): Promise<Todo> {
    return this.todoService.create(createTodoDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all todos with optional filtering' })
  @ApiResponse({
    status: 200,
    description: 'Return all todos matching the filters.',
    type: [Todo],
  })
  @ApiQuery({ name: 'status', required: false, enum: ['completed', 'pending'] })
  @ApiQuery({ name: 'priority', required: false, enum: ['low', 'medium', 'high', 'urgent'] })
  @ApiQuery({ name: 'category', required: false, type: String })
  @ApiQuery({ name: 'startDate', required: false, type: String, description: 'YYYY-MM-DD format' })
  @ApiQuery({ name: 'endDate', required: false, type: String, description: 'YYYY-MM-DD format' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search in title and description' })
  findAll(
    @Query('status') status?: 'completed' | 'pending',
    @Query('priority') priority?: string,
    @Query('category') category?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('search') search?: string,
  ): Promise<Todo[]> {
    const filters = { status, priority, category, startDate, endDate, search };
    return this.todoService.findAll(filters);
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Get todo statistics' })
  @ApiResponse({
    status: 200,
    description: 'Return todo statistics.',
    type: TodoStatisticsDto,
  })
  getStatistics(): Promise<TodoStatisticsDto> {
    return this.todoService.getStatistics();
  }

  @Get('overdue')
  @ApiOperation({ summary: 'Get overdue todos' })
  @ApiResponse({
    status: 200,
    description: 'Return all overdue todos.',
    type: [Todo],
  })
  findOverdue(): Promise<Todo[]> {
    return this.todoService.findOverdue();
  }

  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming todos' })
  @ApiResponse({
    status: 200,
    description: 'Return todos due in the next 7 days (or specified days).',
    type: [Todo],
  })
  @ApiQuery({ name: 'days', required: false, type: Number, description: 'Number of days to look ahead (default: 7)' })
  findUpcoming(@Query('days') days?: number): Promise<Todo[]> {
    return this.todoService.findUpcoming(days ? parseInt(days.toString()) : 7);
  }

  @Get('category/:category')
  @ApiOperation({ summary: 'Get todos by category' })
  @ApiParam({ name: 'category', type: String })
  @ApiResponse({
    status: 200,
    description: 'Return todos in the specified category.',
    type: [Todo],
  })
  findByCategory(@Param('category') category: string): Promise<Todo[]> {
    return this.todoService.findByCategory(category);
  }

  @Get('priority/:priority')
  @ApiOperation({ summary: 'Get todos by priority' })
  @ApiParam({ name: 'priority', enum: ['low', 'medium', 'high', 'urgent'] })
  @ApiResponse({
    status: 200,
    description: 'Return todos with the specified priority.',
    type: [Todo],
  })
  findByPriority(@Param('priority') priority: string): Promise<Todo[]> {
    return this.todoService.findByPriority(priority);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a todo by id' })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({
    status: 200,
    description: 'Return the todo with the specified id.',
    type: Todo,
  })
  @ApiNotFoundResponse({ description: 'Todo not found' })
  findOne(@Param('id') id: string): Promise<Todo> {
    return this.todoService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a todo' })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({
    status: 200,
    description: 'The todo has been successfully updated.',
    type: Todo,
  })
  @ApiNotFoundResponse({ description: 'Todo not found' })
  @ApiBadRequestResponse({ description: 'Invalid input data' })
  update(
    @Param('id') id: string,
    @Body(ValidationPipe) updateTodoDto: UpdateTodoDto,
  ): Promise<Todo> {
    return this.todoService.update(id, updateTodoDto);
  }

  @Patch(':id/toggle')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Toggle todo completion status' })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({
    status: 200,
    description: 'The todo completion status has been toggled.',
    type: Todo,
  })
  @ApiNotFoundResponse({ description: 'Todo not found' })
  toggleDone(@Param('id') id: string): Promise<Todo> {
    return this.todoService.toggleDone(id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a todo' })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({
    status: 204,
    description: 'The todo has been successfully deleted.',
  })
  @ApiNotFoundResponse({ description: 'Todo not found' })
  remove(@Param('id') id: string): Promise<void> {
    return this.todoService.remove(id);
  }
}