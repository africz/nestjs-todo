export interface Todo {
  id: string;
  title: string;
  description: string;
  date: string; // ISO date string
  hours: number; // estimated hours to complete
  done: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface CreateTodoDto {
  title: string;
  description: string;
  date: string;
  hours: number;
}

export interface UpdateTodoDto {
  title?: string;
  description?: string;
  date?: string;
  hours?: number;
  done?: boolean;
}