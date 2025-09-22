import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThan } from 'typeorm';
import { Todo } from './entities/todo.entity';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';
import { TodoStatisticsDto } from './dto/todo-statistics.dto';

@Injectable()
export class TodoService {
  constructor(
    @InjectRepository(Todo)
    private readonly todoRepository: Repository<Todo>,
  ) {}

  async create(createTodoDto: CreateTodoDto): Promise<Todo> {
    const todo = this.todoRepository.create(createTodoDto);
    return await this.todoRepository.save(todo);
  }

  async findAll(filters?: {
    status?: 'completed' | 'pending';
    priority?: string;
    category?: string;
    startDate?: string;
    endDate?: string;
    search?: string;
  }): Promise<Todo[]> {
    const query = this.todoRepository.createQueryBuilder('todo');

    if (filters?.status === 'completed') {
      query.where('todo.done = :done', { done: true });
    } else if (filters?.status === 'pending') {
      query.where('todo.done = :done', { done: false });
    }

    if (filters?.priority) {
      query.andWhere('todo.priority = :priority', { priority: filters.priority });
    }

    if (filters?.category) {
      query.andWhere('todo.category = :category', { category: filters.category });
    }

    if (filters?.startDate && filters?.endDate) {
      query.andWhere('todo.date BETWEEN :startDate AND :endDate', {
        startDate: filters.startDate,
        endDate: filters.endDate,
      });
    } else if (filters?.startDate) {
      query.andWhere('todo.date >= :startDate', { startDate: filters.startDate });
    } else if (filters?.endDate) {
      query.andWhere('todo.date <= :endDate', { endDate: filters.endDate });
    }

    if (filters?.search) {
      query.andWhere(
        '(todo.title LIKE :search OR todo.description LIKE :search)',
        { search: `%${filters.search}%` },
      );
    }

    return await query.orderBy('todo.date', 'ASC').getMany();
  }

  async findOne(id: string): Promise<Todo> {
    const todo = await this.todoRepository.findOne({ where: { id } });
    if (!todo) {
      throw new NotFoundException(`Todo with ID "${id}" not found`);
    }
    return todo;
  }

  async update(id: string, updateTodoDto: UpdateTodoDto): Promise<Todo> {
    const todo = await this.findOne(id);
    
    // If marking as done, set completedAt timestamp
    if (updateTodoDto.done === true && !todo.done) {
      updateTodoDto.completedAt = new Date();
    }
    // If marking as not done, clear completedAt timestamp
    else if (updateTodoDto.done === false && todo.done) {
      updateTodoDto.completedAt = null;
    }

    Object.assign(todo, updateTodoDto);
    return await this.todoRepository.save(todo);
  }

  async remove(id: string): Promise<void> {
    const result = await this.todoRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Todo with ID "${id}" not found`);
    }
  }

  async toggleDone(id: string): Promise<Todo> {
    const todo = await this.findOne(id);
    return await this.update(id, { 
      done: !todo.done,
      completedAt: !todo.done ? new Date() : null,
    });
  }

  async getStatistics(): Promise<TodoStatisticsDto> {
    const todos = await this.todoRepository.find();
    const today = new Date().toISOString().split('T')[0];

    const total = todos.length;
    const completed = todos.filter(todo => todo.done).length;
    const pending = total - completed;
    
    const totalHours = todos.reduce((sum, todo) => sum + Number(todo.hours), 0);
    const completedHours = todos
      .filter(todo => todo.done)
      .reduce((sum, todo) => sum + Number(todo.hours), 0);
    const pendingHours = totalHours - completedHours;

    const overdue = todos.filter(
      todo => !todo.done && todo.date < today
    ).length;

    // Priority breakdown
    const byPriority = {
      low: todos.filter(todo => todo.priority === 'low').length,
      medium: todos.filter(todo => todo.priority === 'medium').length,
      high: todos.filter(todo => todo.priority === 'high').length,
      urgent: todos.filter(todo => todo.priority === 'urgent').length,
    };

    // Category breakdown
    const byCategory: Record<string, number> = {};
    todos.forEach(todo => {
      if (todo.category) {
        byCategory[todo.category] = (byCategory[todo.category] || 0) + 1;
      }
    });

    return {
      total,
      completed,
      pending,
      totalHours,
      completedHours,
      pendingHours,
      overdue,
      byPriority,
      byCategory,
    };
  }

  async findByCategory(category: string): Promise<Todo[]> {
    return await this.todoRepository.find({
      where: { category },
      order: { date: 'ASC' },
    });
  }

  async findByPriority(priority: string): Promise<Todo[]> {
    return await this.todoRepository.find({
      where: { priority },
      order: { date: 'ASC' },
    });
  }

  async findOverdue(): Promise<Todo[]> {
    const today = new Date().toISOString().split('T')[0];
    return await this.todoRepository.find({
      where: {
        done: false,
        date: LessThan(today),
      },
      order: { date: 'ASC' },
    });
  }

  async findUpcoming(days: number = 7): Promise<Todo[]> {
    const today = new Date();
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + days);

    const startDate = today.toISOString().split('T')[0];
    const endDate = futureDate.toISOString().split('T')[0];

    return await this.todoRepository.find({
      where: {
        done: false,
        date: Between(startDate, endDate),
      },
      order: { date: 'ASC' },
    });
  }
}