class TodoApp {
    constructor() {
        this.apiBase = '/api/todos';
        this.currentFilter = 'all';
        this.editingTodo = null;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadTodos();
        this.loadStatistics();
        
        // Set default date to today
        document.getElementById('date').valueAsDate = new Date();
    }

    setupEventListeners() {
        // Form submission
        document.getElementById('todo-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveTodo();
        });

        // Cancel edit
        document.getElementById('cancel-btn').addEventListener('click', () => {
            this.cancelEdit();
        });

        // Filter buttons
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.setFilter(e.target.dataset.filter);
            });
        });
    }

    async loadTodos() {
        try {
            this.showLoading(true);
            let url = this.apiBase;
            
            if (this.currentFilter !== 'all') {
                url += `?status=${this.currentFilter}`;
            }
            
            const response = await fetch(url);
            const todos = await response.json();
            this.renderTodos(todos);
        } catch (error) {
            console.error('Error loading todos:', error);
            this.showError('Failed to load todos');
        } finally {
            this.showLoading(false);
        }
    }

    async loadStatistics() {
        try {
            const response = await fetch(`${this.apiBase}/statistics`);
            const stats = await response.json();
            this.renderStatistics(stats);
        } catch (error) {
            console.error('Error loading statistics:', error);
        }
    }

    renderStatistics(stats) {
        document.getElementById('total-todos').textContent = stats.total;
        document.getElementById('completed-todos').textContent = stats.completed;
        document.getElementById('pending-todos').textContent = stats.pending;
        document.getElementById('total-hours').textContent = stats.totalHours;
        document.getElementById('completed-hours').textContent = stats.completedHours;
        document.getElementById('pending-hours').textContent = stats.pendingHours;
    }

    renderTodos(todos) {
        const todoList = document.getElementById('todo-list');
        const noTodos = document.getElementById('no-todos');

        if (todos.length === 0) {
            todoList.innerHTML = '';
            noTodos.style.display = 'block';
            return;
        }

        noTodos.style.display = 'none';
        todoList.innerHTML = todos.map(todo => this.createTodoHTML(todo)).join('');
    }

    createTodoHTML(todo) {
        const dueDate = new Date(todo.date);
        const isOverdue = !todo.done && dueDate < new Date();
        const dueDateStr = dueDate.toLocaleDateString();
        
        return `
            <div class="todo-item ${todo.done ? 'completed' : ''} ${this.editingTodo === todo.id ? 'edit-mode' : ''}" data-id="${todo.id}">
                <div class="d-flex justify-content-between align-items-start">
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center mb-2">
                            <div class="form-check me-3">
                                <input class="form-check-input" type="checkbox" ${todo.done ? 'checked' : ''} 
                                       onchange="todoApp.toggleTodo('${todo.id}')">
                            </div>
                            <h6 class="mb-0 ${todo.done ? 'text-muted' : ''}">${this.escapeHtml(todo.title)}</h6>
                            ${isOverdue ? '<span class="badge bg-danger ms-2">Overdue</span>' : ''}
                        </div>
                        ${todo.description ? `<p class="text-muted mb-2">${this.escapeHtml(todo.description)}</p>` : ''}
                        <div class="small text-muted">
                            <i class="fas fa-calendar me-1"></i>
                            ${dueDateStr}
                            <span class="ms-3">
                                <i class="fas fa-clock me-1"></i>
                                ${todo.hours}h
                            </span>
                        </div>
                    </div>
                    <div class="btn-group" role="group">
                        <button type="button" class="btn btn-outline-primary btn-sm" 
                                onclick="todoApp.editTodo('${todo.id}')" title="Edit">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button type="button" class="btn btn-outline-danger btn-sm" 
                                onclick="todoApp.deleteTodo('${todo.id}')" title="Delete">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;
    }

    async saveTodo() {
        const form = document.getElementById('todo-form');
        const formData = new FormData(form);
        
        const todoData = {
            title: formData.get('title').trim(),
            description: formData.get('description').trim(),
            date: formData.get('date'),
            hours: parseFloat(formData.get('hours'))
        };

        if (!todoData.title) {
            this.showError('Title is required');
            return;
        }

        try {
            let response;
            const todoId = document.getElementById('todo-id').value;
            
            if (todoId) {
                // Update existing todo
                response = await fetch(`${this.apiBase}/${todoId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(todoData)
                });
            } else {
                // Create new todo
                response = await fetch(this.apiBase, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(todoData)
                });
            }

            if (response.ok) {
                this.resetForm();
                this.loadTodos();
                this.loadStatistics();
                this.showSuccess(todoId ? 'Todo updated successfully!' : 'Todo added successfully!');
            } else {
                const error = await response.json();
                this.showError(error.message || 'Failed to save todo');
            }
        } catch (error) {
            console.error('Error saving todo:', error);
            this.showError('Failed to save todo');
        }
    }

    async editTodo(id) {
        try {
            const response = await fetch(`${this.apiBase}/${id}`);
            const todo = await response.json();
            
            this.editingTodo = id;
            document.getElementById('todo-id').value = id;
            document.getElementById('title').value = todo.title;
            document.getElementById('description').value = todo.description;
            document.getElementById('date').value = todo.date.split('T')[0];
            document.getElementById('hours').value = todo.hours;
            
            document.getElementById('form-title').textContent = 'Edit Todo';
            document.getElementById('submit-btn-text').textContent = 'Update Todo';
            document.getElementById('cancel-btn').style.display = 'block';
            
            // Highlight the todo being edited
            this.loadTodos();
            
            // Scroll to form
            document.getElementById('todo-form').scrollIntoView({ behavior: 'smooth' });
        } catch (error) {
            console.error('Error loading todo for edit:', error);
            this.showError('Failed to load todo for editing');
        }
    }

    cancelEdit() {
        this.resetForm();
        this.loadTodos(); // Remove edit highlighting
    }

    resetForm() {
        this.editingTodo = null;
        document.getElementById('todo-form').reset();
        document.getElementById('todo-id').value = '';
        document.getElementById('form-title').textContent = 'Add New Todo';
        document.getElementById('submit-btn-text').textContent = 'Add Todo';
        document.getElementById('cancel-btn').style.display = 'none';
        document.getElementById('date').valueAsDate = new Date();
    }

    async toggleTodo(id) {
        try {
            const response = await fetch(`${this.apiBase}/${id}/toggle`, {
                method: 'PUT'
            });
            
            if (response.ok) {
                this.loadTodos();
                this.loadStatistics();
            } else {
                this.showError('Failed to update todo status');
            }
        } catch (error) {
            console.error('Error toggling todo:', error);
            this.showError('Failed to update todo status');
        }
    }

    async deleteTodo(id) {
        if (!confirm('Are you sure you want to delete this todo?')) {
            return;
        }

        try {
            const response = await fetch(`${this.apiBase}/${id}`, {
                method: 'DELETE'
            });
            
            if (response.ok) {
                this.loadTodos();
                this.loadStatistics();
                this.showSuccess('Todo deleted successfully!');
                
                // If we were editing this todo, reset the form
                if (this.editingTodo === id) {
                    this.resetForm();
                }
            } else {
                this.showError('Failed to delete todo');
            }
        } catch (error) {
            console.error('Error deleting todo:', error);
            this.showError('Failed to delete todo');
        }
    }

    setFilter(filter) {
        this.currentFilter = filter;
        
        // Update button states
        document.querySelectorAll('.filter-btn').forEach(btn => {
            btn.classList.remove('active');
            if (btn.dataset.filter === filter) {
                btn.classList.add('active');
            }
        });
        
        this.loadTodos();
    }

    showLoading(show) {
        document.getElementById('loading').style.display = show ? 'block' : 'none';
    }

    showError(message) {
        this.showToast(message, 'danger');
    }

    showSuccess(message) {
        this.showToast(message, 'success');
    }

    showToast(message, type) {
        // Create toast element
        const toast = document.createElement('div');
        toast.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
        toast.style.cssText = 'top: 20px; right: 20px; z-index: 1050; min-width: 300px;';
        toast.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        
        document.body.appendChild(toast);
        
        // Auto remove after 5 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 5000);
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.todoApp = new TodoApp();
});