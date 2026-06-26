'use strict';
class Task {
    constructor(title, description = '', priority = 'medium') {
        this.id = Date.now().toString(36) + Math.random().toString(36).substr(2);
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.status = 'todo';
        this.createdAt = new Date().toISOString();
        this.updatedAt = new Date().toISOString();
    }
}

const App = {
    tasks: [],
    init() { this.loadTasks(); this.render(); },
    loadTasks() { const s = localStorage.getItem('tasks'); if(s) this.tasks = JSON.parse(s); },
    saveTasks() { localStorage.setItem('tasks', JSON.stringify(this.tasks)); },
    addTask(t,d,p) { const task = new Task(t,d,p); this.tasks.unshift(task); this.saveTasks(); this.render(); return task; },
    deleteTask(id) { this.tasks = this.tasks.filter(t=>t.id!==id); this.saveTasks(); this.render(); },
    toggleTask(id) { const t=this.tasks.find(x=>x.id===id); if(t){t.status=t.status==='done'?'todo':'done'; t.updatedAt=new Date().toISOString(); this.saveTasks(); this.render();} },
    render() { console.log('render', this.tasks.length, 'tasks'); }
};
document.addEventListener('DOMContentLoaded', () => App.init());
