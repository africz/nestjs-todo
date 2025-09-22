import { Injectable } from '@nestjs/common';
import type { Todo, CreateTodoDto, UpdateTodoDto } from './todo.interface';
import * as crypto from 'crypto';

@Injectable()
export class TodoService {
  private todos: Todo[] = [];

  findAll(): Todo[] {
    return this.todos.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  }

  findOne(id: string): Todo | undefined {
    return this.todos.find(todo => todo.id === id);
  }

  create(createTodoDto: CreateTodoDto): Todo {
    const now = new Date().toISOString();
    const newTodo: Todo = {
      id: crypto.randomUUID(),
      ...createTodoDto,
      done: false,
      createdAt: now,
      updatedAt: now,
    };
    
    this.todos.push(newTodo);
    return newTodo;
  }

  update(id: string, updateTodoDto: UpdateTodoDto): Todo | null {
    const todoIndex = this.todos.findIndex(todo => todo.id === id);
    
    if (todoIndex === -1) {
      return null;
    }

    const updatedTodo: Todo = {
      ...this.todos[todoIndex],
      ...updateTodoDto,
      updatedAt: new Date().toISOString(),
    };

    this.todos[todoIndex] = updatedTodo;
    return updatedTodo;
  }

  delete(id: string): boolean {
    const todoIndex = this.todos.findIndex(todo => todo.id === id);
    
    if (todoIndex === -1) {
      return false;
    }

    this.todos.splice(todoIndex, 1);
    return true;
  }

  toggleDone(id: string): Todo | null {
    const todo = this.findOne(id);
    
    if (!todo) {
      return null;
    }

    return this.update(id, { done: !todo.done });
  }

  // Helper methods for filtering
  findByStatus(done: boolean): Todo[] {
    return this.todos.filter(todo => todo.done === done);
  }

  findByDateRange(startDate: string, endDate: string): Todo[] {
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    return this.todos.filter(todo => {
      const todoDate = new Date(todo.date);
      return todoDate >= start && todoDate <= end;
    });
  }

  // Get statistics
  getStatistics() {
    const total = this.todos.length;
    const completed = this.todos.filter(todo => todo.done).length;
    const pending = total - completed;
    const totalHours = this.todos.reduce((sum, todo) => sum + todo.hours, 0);
    const completedHours = this.todos
      .filter(todo => todo.done)
      .reduce((sum, todo) => sum + todo.hours, 0);

    return {
      total,
      completed,
      pending,
      totalHours,
      completedHours,
      pendingHours: totalHours - completedHours,
    };
  }
}