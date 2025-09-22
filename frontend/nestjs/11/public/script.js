const API_URL = window.backendApiUrl;

document.addEventListener('DOMContentLoaded', () => {
    fetchTodos();
    fetchStatistics();
    setupEventListeners();
});

async function fetchTodos(filter = '') {
    let url = API_URL;
    if (filter === 'completed') {
        url = `${API_URL}?status=completed`;
    } else if (filter === 'pending') {
        url = `${API_URL}?status=pending`;
    }
    try {
        const response = await fetch(url);
        const todos = await response.json();
        renderTodos(todos);
    } catch (error) {
        console.error('Error fetching todos:', error);
    }
}

async function addTodo(event) {
    event.preventDefault();
    const title = document.getElementById('title').value.trim();
    const description = document.getElementById('description').value.trim();
    const date = document.getElementById('date').value;
    const hours = parseFloat(document.getElementById('hours').value);

    if (!title) {
        return alert('Title is required');
    }

    const todoData = { title, description, date, hours };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(todoData)
        });
        if (response.ok) {
            document.getElementById('todo-form').reset();
            fetchTodos();
            fetchStatistics();
        } else {
            const error = await response.json();
            alert(error.message || 'Failed to add todo');
        }
    } catch (error) {
        console.error('Error adding todo:', error);
        alert('Failed to add todo');
    }
}

async function updateTodo(id, data) {
    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
        if (response.ok) {
            fetchTodos();
            fetchStatistics();
        } else {
            const error = await response.json();
            alert(error.message || 'Failed to update todo');
        }
    } catch (error) {
        console.error('Error updating todo:', error);
        alert('Failed to update todo');
    }
}

async function deleteTodo(id) {
    if (confirm('Are you sure you want to delete this todo?')) {
        try {
            await fetch(`${API_URL}/${id}`, {
                method: 'DELETE'
            });
            fetchTodos();
            fetchStatistics();
        } catch (error) {
            console.error('Error deleting todo:', error);
            alert('Failed to delete todo');
        }
    }
}

async function toggleDone(id, currentStatus) {
    try {
        await fetch(`${API_URL}/${id}`, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ done: !currentStatus })
        });
        fetchTodos();
        fetchStatistics();
    } catch (error) {
        console.error('Error toggling todo status:', error);
        alert('Failed to update todo status');
    }
}

async function fetchStatistics() {
    try {
        const response = await fetch(`${API_URL}/statistics`);
        const stats = await response.json();
        document.getElementById('total-todos').textContent = stats.total;
        document.getElementById('completed-todos').textContent = stats.completed;
        document.getElementById('pending-todos').textContent = stats.pending;
        document.getElementById('total-hours').textContent = stats.totalHours;
        document.getElementById('completed-hours').textContent = stats.completedHours;
        document.getElementById('pending-hours').textContent = stats.pendingHours;
    } catch (error) {
        console.error('Error fetching statistics:', error);
    }
}

function setupEventListeners() {
    document.getElementById('todo-form').addEventListener('submit', function(event) {
        event.preventDefault();
        const id = document.getElementById('todo-id').value;
        if (id) {
            updateTodo(id, {
                title: this.title.value,
                description: this.description.value,
                date: this.date.value,
                hours: parseFloat(this.hours.value)
            });
            this.reset();
            document.getElementById('todo-id').value = '';
        } else {
            addTodo(event);
        }
    });

    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const filter = e.target.dataset.filter;
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');
            fetchTodos(filter);
        });
    });
}

function renderTodos(todos) {
    const todoList = document.getElementById('todo-list');
    todoList.innerHTML = '';

    todos.forEach(todo => {
        const todoItem = document.createElement('div');
        todoItem.className = `todo-item ${todo.done ? 'completed' : ''}`;
        todoItem.dataset.id = todo.id;

        todoItem.innerHTML = `
            <div class="todo-content">
                <div class="todo-title">${escapeHtml(todo.title)}</div>
                <div class="todo-description">${escapeHtml(todo.description)}</div>
                <div class="todo-meta">
                    <span class="todo-date">${new Date(todo.date).toLocaleDateString()}</span>
                    <span class="todo-hours">${todo.hours}h</span>
                </div>
            </div>
            <div class="todo-actions">
                <button class="btn btn-sm btn-primary" onclick="editTodo('${todo.id}')">Edit</button>
                <button class="btn btn-sm btn-danger" onclick="deleteTodo('${todo.id}')">Delete</button>
                <button class="btn btn-sm ${todo.done ? 'btn-secondary' : 'btn-success'}" 
                        onclick="toggleDone('${todo.id}', ${todo.done})">
                    ${todo.done ? 'Undo' : 'Complete'}
                </button>
            </div>
        `;

        todoList.appendChild(todoItem);
    });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function editTodo(id) {
    const todoItem = document.querySelector(`[data-id='${id}']`);
    if (!todoItem) return;

    const title = todoItem.querySelector('.todo-title').textContent;
    const description = todoItem.querySelector('.todo-description').textContent;
    const date = todoItem.querySelector('.todo-date').textContent;
    const hours = todoItem.querySelector('.todo-hours').textContent.replace('h', '');

    document.getElementById('title').value = title;
    document.getElementById('description').value = description;
    document.getElementById('date').value = new Date(date).toISOString().split('T')[0];
    document.getElementById('hours').value = hours;
    document.getElementById('todo-id').value = id;
}