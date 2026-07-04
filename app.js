'use strict';
class Task {
    constructor(title, description = '', priority = 'medium') {
        this.id = Date.now().toString(36) + Math.random().toString(36).substr(2);
        this.title = title; this.description = description; this.priority = priority;
        this.status = 'todo'; this.createdAt = new Date().toISOString(); this.updatedAt = new Date().toISOString();
    }
}
const App = {
    tasks: [], currentFilter: 'all', searchQuery: '',
    init() { this.loadTasks(); this.bindEvents(); this.render(); },
    bindEvents() {
        document.getElementById('addTaskForm').addEventListener('submit', (e) => {
            e.preventDefault();
            const t=document.getElementById('taskTitle').value.trim();
            const d=document.getElementById('taskDesc').value.trim();
            const p=document.getElementById('taskPriority').value;
            if(t){this.addTask(t,d,p);e.target.reset();}
        });
    },
    loadTasks() { const s=localStorage.getItem('tasks'); if(s) this.tasks=JSON.parse(s); },
    saveTasks() { localStorage.setItem('tasks', JSON.stringify(this.tasks)); },
    addTask(t,d,p) { const task=new Task(t,d,p); this.tasks.unshift(task); this.saveTasks(); this.render(); this.notify(`Task "${t}" đã được thêm!`); return task; },
    deleteTask(id) { const t=this.tasks.find(x=>x.id===id); this.tasks=this.tasks.filter(x=>x.id!==id); this.saveTasks(); this.render(); if(t) this.notify(`Đã xóa "${t.title}"`); },
    toggleTask(id) { const t=this.tasks.find(x=>x.id===id); if(t){t.status=t.status==='done'?'todo':'done';t.updatedAt=new Date().toISOString();this.saveTasks();this.render();} },
    getFilteredTasks() {
        let f=[...this.tasks];
        if(this.currentFilter!=='all') f=f.filter(t=>t.status===this.currentFilter);
        if(this.searchQuery) f=f.filter(t=>t.title.toLowerCase().includes(this.searchQuery)||t.description.toLowerCase().includes(this.searchQuery));
        return f;
    },
    notify(msg) {
        const n=document.createElement('div'); n.className='notification'; n.textContent=msg;
        document.body.appendChild(n); setTimeout(()=>n.classList.add('show'),10);
        setTimeout(()=>{n.classList.remove('show');setTimeout(()=>n.remove(),300);},2500);
    },
    escapeHtml(t) { const d=document.createElement('div'); d.textContent=t; return d.innerHTML; },
    formatDate(s) { return new Date(s).toLocaleDateString('vi-VN',{day:'2-digit',month:'2-digit'}); },
    updateStats() { const total=this.tasks.length; const done=this.tasks.filter(t=>t.status==='done').length; const el=document.getElementById('taskStats'); if(el) el.textContent=`${done}/${total} hoàn thành`; },
    render() {
        const container=document.getElementById('taskList'); const tasks=this.getFilteredTasks(); this.updateStats();
        if(tasks.length===0){container.innerHTML='<p class="empty-state">Không có task nào 🎯</p>';return;}
        container.innerHTML=tasks.map(t=>`
            <div class="task-card ${t.status==='done'?'done':''}" data-id="${t.id}">
                <input type="checkbox" ${t.status==='done'?'checked':''} onchange="App.toggleTask('${t.id}')">
                <div class="task-info">
                    <div class="task-title">${this.escapeHtml(t.title)}</div>
                    ${t.description?`<div class="task-desc">${this.escapeHtml(t.description)}</div>`:''}
                    <div class="task-meta">
                        <span class="priority-badge ${t.priority}">${t.priority}</span>
                        <span class="task-date">${this.formatDate(t.createdAt)}</span>
                    </div>
                </div>
                <button class="btn-delete" onclick="App.deleteTask('${t.id}')">🗑️</button>
            </div>
        `).join('');
    }
};
document.addEventListener('DOMContentLoaded', () => App.init());
