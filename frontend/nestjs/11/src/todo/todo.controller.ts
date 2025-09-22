import { 
  Controller, 
  Get, 
  Post, 
  Put, 
  Delete, 
  Body, 
  Param, 
  Query,
  NotFoundException,
  BadRequestException,
  HttpCode,
  HttpStatus
} from '@nestjs/common';
import { TodoService } from './todo.service';
import type { CreateTodoDto, UpdateTodoDto } from './todo.interface';

@Controller('api/todos')
export class TodoController {
  constructor(private readonly todoService: TodoService) {}

  @Get()
  findAll(@Query('status') status?: string, @Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    if (status === 'completed') {
      return this.todoService.findByStatus(true);
    }
    
    if (status === 'pending') {
      return this.todoService.findByStatus(false);
    }
    
    if (startDate && endDate) {
      return this.todoService.findByDateRange(startDate, endDate);
    }
    
    return this.todoService.findAll();
  }

  @Get('statistics')
  getStatistics() {
    return this.todoService.getStatistics();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    const todo = this.todoService.findOne(id);
    
    if (!todo) {
      throw new NotFoundException(`Todo with id ${id} not found`);
    }
    
    return todo;
  }

  @Post()
  create(@Body() createTodoDto: CreateTodoDto) {
    // Basic validation
    if (!createTodoDto.title?.trim()) {
      throw new BadRequestException('Title is required');
    }
    
    if (!createTodoDto.date) {
      throw new BadRequestException('Date is required');
    }
    
    if (createTodoDto.hours < 0) {
      throw new BadRequestException('Hours must be a positive number');
    }
    
    // Validate date format
    const date = new Date(createTodoDto.date);
    if (isNaN(date.getTime())) {
      throw new BadRequestException('Invalid date format');
    }
    
    return this.todoService.create(createTodoDto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateTodoDto: UpdateTodoDto) {
    // Validate hours if provided
    if (updateTodoDto.hours !== undefined && updateTodoDto.hours < 0) {
      throw new BadRequestException('Hours must be a positive number');
    }
    
    // Validate date if provided
    if (updateTodoDto.date) {
      const date = new Date(updateTodoDto.date);
      if (isNaN(date.getTime())) {
        throw new BadRequestException('Invalid date format');
      }
    }
    
    const updatedTodo = this.todoService.update(id, updateTodoDto);
    
    if (!updatedTodo) {
      throw new NotFoundException(`Todo with id ${id} not found`);
    }
    
    return updatedTodo;
  }

  @Put(':id/toggle')
  @HttpCode(HttpStatus.OK)
  toggleDone(@Param('id') id: string) {
    const updatedTodo = this.todoService.toggleDone(id);
    
    if (!updatedTodo) {
      throw new NotFoundException(`Todo with id ${id} not found`);
    }
    
    return updatedTodo;
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  delete(@Param('id') id: string) {
    const deleted = this.todoService.delete(id);
    
    if (!deleted) {
      throw new NotFoundException(`Todo with id ${id} not found`);
    }
  }
}