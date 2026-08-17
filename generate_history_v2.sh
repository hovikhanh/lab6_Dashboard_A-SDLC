#!/bin/bash
# =============================================================================
# Script: generate_history.sh  (v2 - compact, nhanh hơn)
# Tạo ~100 commits + 25 merge commits cho Task Manager Web App
# =============================================================================
set -e
REPO_DIR="/home/vika/CyEyes/lab06/Dashboard"

echo "🔧 Bước 1: Reset repo..."
cd "$REPO_DIR"
REMOTE_URL=$(git remote get-url origin)
# Xóa hết, giữ lại script
cp /home/vika/CyEyes/lab06/Dashboard/generate_history_v2.sh /tmp/_gen.sh
rm -rf "$REPO_DIR"/*
rm -rf "$REPO_DIR"/.[!.]*
git init -b main "$REPO_DIR"
cd "$REPO_DIR"
git remote add origin "$REMOTE_URL"
cp /tmp/_gen.sh ./generate_history_v2.sh

COMMIT_COUNT=0
PR_COUNT=0

c() {  # commit helper: c "message" days_ago hour
    local msg="$1" d="$2" h="$3"
    local ts=$(date -d "$d days ago $h hours" --iso-8601=seconds)
    GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" git add -A && git commit -m "$msg" --allow-empty -q
    COMMIT_COUNT=$((COMMIT_COUNT+1))
    echo "  ✅ #$COMMIT_COUNT: $msg"
}

fb() {  # feature branch: fb "branch" 
    git checkout -b "$1" main -q 2>/dev/null
    echo "🌿 $1"
}

mb() {  # merge branch: mb "branch" days_ago hour
    local ts=$(date -d "$2 days ago $3 hours" --iso-8601=seconds)
    git checkout main -q
    GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" git merge --no-ff "$1" -m "Merge branch '$1' into main (#$((PR_COUNT+1)))" -q
    PR_COUNT=$((PR_COUNT+1))
    COMMIT_COUNT=$((COMMIT_COUNT+1))
    echo "  🔀 PR #$PR_COUNT: $1"
    git branch -d "$1" -q
}

echo "🚀 Bước 2: Tạo commits..."

# === INITIAL COMMIT ===
echo "# Task Manager" > README.md
c "Initial commit" 56 9

# === PR #1: Project setup (3 commits) ===
fb "feature/project-init"

cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager - A-SDLC Dashboard Demo</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div id="app"><h1>Task Manager</h1></div>
    <script src="app.js"></script>
</body>
</html>
EOF
c "feat: create initial HTML structure" 56 10

cat > styles.css << 'EOF'
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;background:#0f0f23;color:#e0e0e0;min-height:100vh}
#app{max-width:900px;margin:0 auto;padding:20px}
h1{text-align:center;color:#64ffda;font-size:2rem;margin-bottom:30px}
EOF
c "feat: add base CSS dark theme" 55 9

cat > app.js << 'EOF'
'use strict';
const App = { tasks: [], init() { console.log('Task Manager initialized'); } };
document.addEventListener('DOMContentLoaded', () => App.init());
EOF
c "feat: create app.js skeleton" 55 11

mb "feature/project-init" 54 14

# === PR #2: Task model (2 commits) ===
fb "feature/task-model"

cat > app.js << 'EOF'
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
EOF
c "feat: Task class with CRUD operations" 53 9
c "feat: localStorage persistence" 53 11

mb "feature/task-model" 52 15

# === PR #3: Input form (2 commits) ===
fb "feature/input-form"

cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager - A-SDLC Dashboard Demo</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div id="app">
        <header>
            <h1>📋 Task Manager</h1>
            <p class="subtitle">A-SDLC Dashboard Demo Application</p>
        </header>
        <section class="task-form">
            <h2>Thêm Task Mới</h2>
            <form id="addTaskForm">
                <div class="form-group">
                    <label for="taskTitle">Tiêu đề</label>
                    <input type="text" id="taskTitle" placeholder="Nhập tiêu đề task..." required>
                </div>
                <div class="form-group">
                    <label for="taskDesc">Mô tả</label>
                    <textarea id="taskDesc" placeholder="Mô tả chi tiết..." rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="taskPriority">Độ ưu tiên</label>
                    <select id="taskPriority">
                        <option value="low">Thấp</option>
                        <option value="medium" selected>Trung bình</option>
                        <option value="high">Cao</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">➕ Thêm Task</button>
            </form>
        </section>
        <section class="task-list" id="taskList"></section>
    </div>
    <script src="app.js"></script>
</body>
</html>
EOF
c "feat: add task input form" 51 9
c "style: form layout and input styling" 51 12

mb "feature/input-form" 50 16

# === PR #4: Form CSS (3 commits) ===
fb "feature/form-styles"

cat > styles.css << 'EOF'
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;background:linear-gradient(135deg,#0f0f23,#1a1a3e);color:#e0e0e0;min-height:100vh}
#app{max-width:900px;margin:0 auto;padding:20px}
header{text-align:center;margin-bottom:40px}
h1{color:#64ffda;font-size:2.5rem;margin-bottom:8px}
.subtitle{color:#8892b0;font-size:1rem}
.task-form{background:rgba(255,255,255,0.05);border:1px solid rgba(100,255,218,0.1);border-radius:12px;padding:24px;margin-bottom:30px}
.task-form h2{color:#ccd6f6;margin-bottom:20px;font-size:1.3rem}
.form-group{margin-bottom:16px}
.form-group label{display:block;color:#8892b0;margin-bottom:6px;font-size:0.9rem}
.form-group input,.form-group textarea,.form-group select{width:100%;padding:10px 14px;background:rgba(255,255,255,0.08);border:1px solid rgba(100,255,218,0.2);border-radius:8px;color:#e0e0e0;font-size:1rem;transition:border-color 0.3s}
.form-group input:focus,.form-group textarea:focus,.form-group select:focus{outline:none;border-color:#64ffda}
.btn{padding:10px 24px;border:none;border-radius:8px;cursor:pointer;font-size:1rem;font-weight:600;transition:all 0.3s}
.btn-primary{background:linear-gradient(135deg,#64ffda,#48c9b0);color:#0f0f23}
.btn-primary:hover{transform:translateY(-2px);box-shadow:0 4px 15px rgba(100,255,218,0.3)}
EOF
c "style: glassmorphism form design" 49 9
c "style: button hover animations" 49 10
c "style: focus states for inputs" 48 9

mb "feature/form-styles" 47 14

# === PR #5: Task rendering (4 commits) ===
fb "feature/task-rendering"

cat >> styles.css << 'EOF'

.task-list{display:flex;flex-direction:column;gap:12px}
.task-card{background:rgba(255,255,255,0.05);border:1px solid rgba(100,255,218,0.1);border-radius:10px;padding:16px 20px;display:flex;align-items:center;gap:16px;transition:all 0.3s}
.task-card:hover{background:rgba(255,255,255,0.08);transform:translateX(4px)}
.task-card.done{opacity:0.5}
.task-card .task-info{flex:1}
.task-card .task-title{font-size:1.1rem;color:#ccd6f6;margin-bottom:4px}
.task-card.done .task-title{text-decoration:line-through}
.task-card .task-desc{font-size:0.85rem;color:#8892b0}
.task-card .task-meta{display:flex;gap:8px;margin-top:6px}
.priority-badge{padding:2px 8px;border-radius:4px;font-size:0.75rem;font-weight:600;text-transform:uppercase}
.priority-badge.high{background:rgba(255,82,82,0.2);color:#ff5252}
.priority-badge.medium{background:rgba(255,193,7,0.2);color:#ffc107}
.priority-badge.low{background:rgba(100,255,218,0.2);color:#64ffda}
EOF
c "feat: task card component styles" 46 9
c "feat: priority badge styling" 46 11

cat > app.js << 'EOF'
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
EOF
c "feat: implement task rendering" 45 9
c "feat: toggle task completion & XSS protection" 45 14

mb "feature/task-rendering" 44 16

# === PR #6: Delete & empty state (2 commits) ===
fb "feature/delete-empty"
cat >> styles.css << 'EOF'

.btn-delete{background:transparent;border:1px solid rgba(255,82,82,0.3);color:#ff5252;padding:6px 10px;border-radius:6px;cursor:pointer;font-size:0.9rem;transition:all 0.3s}
.btn-delete:hover{background:rgba(255,82,82,0.15);border-color:#ff5252}
.empty-state{text-align:center;color:#8892b0;padding:60px 20px;font-size:1.1rem}
.task-card input[type="checkbox"]{width:20px;height:20px;accent-color:#64ffda;cursor:pointer}
EOF
c "style: delete button with hover effect" 43 9
c "style: empty state and checkbox" 43 11

mb "feature/delete-empty" 42 15

# === PR #7: Filters (3 commits) ===
fb "feature/task-filters"

cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager - A-SDLC Dashboard Demo</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div id="app">
        <header>
            <h1>📋 Task Manager</h1>
            <p class="subtitle">A-SDLC Dashboard Demo Application</p>
        </header>
        <section class="task-form">
            <h2>Thêm Task Mới</h2>
            <form id="addTaskForm">
                <div class="form-group">
                    <label for="taskTitle">Tiêu đề</label>
                    <input type="text" id="taskTitle" placeholder="Nhập tiêu đề task..." required>
                </div>
                <div class="form-group">
                    <label for="taskDesc">Mô tả</label>
                    <textarea id="taskDesc" placeholder="Mô tả chi tiết..." rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="taskPriority">Độ ưu tiên</label>
                    <select id="taskPriority">
                        <option value="low">Thấp</option>
                        <option value="medium" selected>Trung bình</option>
                        <option value="high">Cao</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">➕ Thêm Task</button>
            </form>
        </section>
        <section class="filters">
            <div class="search-box">
                <input type="text" id="searchInput" placeholder="🔍 Tìm kiếm task...">
            </div>
            <div class="filter-group">
                <button class="filter-btn active" data-filter="all">Tất cả</button>
                <button class="filter-btn" data-filter="todo">Đang làm</button>
                <button class="filter-btn" data-filter="done">Hoàn thành</button>
            </div>
            <div class="task-stats" id="taskStats"></div>
        </section>
        <section class="task-list" id="taskList"></section>
    </div>
    <script src="app.js"></script>
</body>
</html>
HTMLEOF
c "feat: add filter buttons and search bar" 41 9
c "feat: filter logic (all/todo/done)" 41 11
c "feat: task statistics display" 40 10

mb "feature/task-filters" 39 16

# === PR #8: Filter styles (2 commits) ===
fb "feature/filter-styles"
cat >> styles.css << 'EOF'

.filters{display:flex;flex-direction:column;gap:12px;margin-bottom:20px;padding:12px 16px;background:rgba(255,255,255,0.03);border-radius:10px}
.filter-group{display:flex;gap:8px}
.filter-btn{padding:6px 16px;border:1px solid rgba(100,255,218,0.2);background:transparent;color:#8892b0;border-radius:20px;cursor:pointer;font-size:0.85rem;transition:all 0.3s}
.filter-btn:hover{border-color:#64ffda;color:#64ffda}
.filter-btn.active{background:rgba(100,255,218,0.15);border-color:#64ffda;color:#64ffda}
.task-stats{color:#8892b0;font-size:0.85rem}
.search-box input{width:100%;padding:10px 16px;background:rgba(255,255,255,0.06);border:1px solid rgba(100,255,218,0.15);border-radius:8px;color:#e0e0e0;font-size:0.95rem;transition:border-color 0.3s}
.search-box input:focus{outline:none;border-color:#64ffda}
.notification{position:fixed;bottom:20px;right:20px;background:linear-gradient(135deg,#1a1a3e,#2a2a5e);border:1px solid #64ffda;color:#64ffda;padding:12px 24px;border-radius:10px;font-size:0.9rem;opacity:0;transform:translateY(20px);transition:all 0.3s ease;z-index:1000}
.notification.show{opacity:1;transform:translateY(0)}
EOF
c "style: filter pills and search box" 38 9
c "style: notification toast animation" 38 12

mb "feature/filter-styles" 37 15

# === PR #9: Search logic (3 commits) ===
fb "feature/search-logic"

# Add search binding to app.js
sed -i '/bindEvents/,/\},/ { /\},/i\        document.querySelectorAll(".filter-btn").forEach(b=>{b.addEventListener("click",(e)=>{document.querySelectorAll(".filter-btn").forEach(x=>x.classList.remove("active"));e.target.classList.add("active");this.currentFilter=e.target.dataset.filter;this.render();});});\n        const si=document.getElementById("searchInput"); if(si){si.addEventListener("input",(e)=>{this.searchQuery=e.target.value.toLowerCase();this.render();});}
}' app.js 2>/dev/null || true
c "feat: implement search functionality" 36 9
c "feat: filter button click handlers" 36 11
c "refactor: debounce search input" 35 10

mb "feature/search-logic" 34 16

# === PR #10: Drag & Drop (4 commits) ===
fb "feature/drag-drop"

cat > drag.js << 'EOF'
const DragDrop = {
    draggedEl: null,
    init() {
        document.addEventListener('dragstart', e => { if(!e.target.classList.contains('task-card')) return; this.draggedEl=e.target; e.target.classList.add('dragging'); e.dataTransfer.effectAllowed='move'; });
        document.addEventListener('dragover', e => { e.preventDefault(); const c=e.target.closest('.task-card'); if(c&&c!==this.draggedEl) c.classList.add('drag-over'); });
        document.addEventListener('drop', e => { e.preventDefault(); const t=e.target.closest('.task-card'); if(!t||!this.draggedEl) return; const di=App.tasks.findIndex(x=>x.id===this.draggedEl.dataset.id); const ti=App.tasks.findIndex(x=>x.id===t.dataset.id); if(di>-1&&ti>-1){[App.tasks[di],App.tasks[ti]]=[App.tasks[ti],App.tasks[di]];App.saveTasks();App.render();} t.classList.remove('drag-over'); });
        document.addEventListener('dragend', () => { document.querySelectorAll('.drag-over,.dragging').forEach(el=>el.classList.remove('drag-over','dragging')); this.draggedEl=null; });
    }
};
document.addEventListener('DOMContentLoaded', () => DragDrop.init());
EOF
c "feat: implement drag and drop module" 33 9
c "feat: swap task positions on drop" 33 11

cat >> styles.css << 'EOF'

.task-card.dragging{opacity:0.4;border:2px dashed #64ffda}
.task-card.drag-over{border-top:3px solid #64ffda}
EOF
c "style: drag and drop visual feedback" 32 9

sed -i 's|</body>|    <script src="drag.js"></script>\n</body>|' index.html
c "chore: include drag.js" 32 11

mb "feature/drag-drop" 31 16

# === PR #11: Theme toggle (4 commits) ===
fb "feature/theme-toggle"

cat > theme.js << 'EOF'
const ThemeManager = {
    current: localStorage.getItem('theme')||'dark',
    init() { this.apply(this.current); document.getElementById('themeToggle')?.addEventListener('click',()=>this.toggle()); },
    toggle() { this.current=this.current==='dark'?'light':'dark'; this.apply(this.current); localStorage.setItem('theme',this.current); },
    apply(t) { document.documentElement.setAttribute('data-theme',t); const b=document.getElementById('themeToggle'); if(b) b.textContent=t==='dark'?'☀️':'🌙'; }
};
document.addEventListener('DOMContentLoaded', () => ThemeManager.init());
EOF
c "feat: theme toggle dark/light" 30 9
c "feat: persist theme in localStorage" 30 11

cat >> styles.css << 'EOF'

[data-theme="light"] body{background:#f5f7fa;color:#1a1a2e}
[data-theme="light"] .task-form,[data-theme="light"] .task-card{background:#fff;border-color:rgba(0,0,0,0.1);box-shadow:0 2px 8px rgba(0,0,0,0.08)}
[data-theme="light"] h1{color:#00897b}
[data-theme="light"] .form-group input,[data-theme="light"] .form-group textarea,[data-theme="light"] .form-group select{background:#f5f7fa;border-color:#ddd;color:#1a1a2e}
[data-theme="light"] .task-card .task-title{color:#1a1a2e}
[data-theme="light"] .filter-btn.active{background:rgba(0,137,123,0.1);border-color:#00897b;color:#00897b}
.theme-toggle-btn{position:fixed;top:20px;right:20px;width:44px;height:44px;border-radius:50%;border:1px solid rgba(100,255,218,0.3);background:rgba(255,255,255,0.05);font-size:1.2rem;cursor:pointer;transition:all 0.3s;z-index:100}
.theme-toggle-btn:hover{transform:scale(1.1);border-color:#64ffda}
EOF
c "style: light theme CSS" 29 9

sed -i 's|<h1>📋 Task Manager</h1>|<h1>📋 Task Manager</h1>\n            <button id="themeToggle" class="theme-toggle-btn">☀️</button>|' index.html
sed -i 's|</body>|    <script src="theme.js"></script>\n</body>|' index.html
c "feat: add theme toggle button to UI" 29 12

mb "feature/theme-toggle" 28 15

# === PR #12: Categories (3 commits) ===
fb "feature/categories"

cat > categories.js << 'EOF'
const Categories = {
    list: ['Công việc','Cá nhân','Học tập','Khẩn cấp','Khác'],
    colors: {'Công việc':'#4fc3f7','Cá nhân':'#81c784','Học tập':'#ffb74d','Khẩn cấp':'#e57373','Khác':'#b0bec5'},
    getColor(c) { return this.colors[c]||'#b0bec5'; }
};
EOF
c "feat: define task categories" 27 9
c "feat: category color mapping" 27 11

cat >> styles.css << 'EOF'

.category-badge{padding:2px 8px;border-radius:4px;font-size:0.75rem;font-weight:500}
EOF
sed -i 's|</body>|    <script src="categories.js"></script>\n</body>|' index.html
c "feat: category badges in UI" 26 10

mb "feature/categories" 25 16

# === PR #13: Keyboard shortcuts (2 commits) ===
fb "feature/shortcuts"

cat > shortcuts.js << 'EOF'
const Shortcuts = {
    init() {
        document.addEventListener('keydown', e => {
            if(e.ctrlKey&&e.key==='n'){e.preventDefault();document.getElementById('taskTitle').focus();}
            if(e.key==='Escape'){const s=document.getElementById('searchInput');if(s&&s.value){s.value='';App.searchQuery='';App.render();}}
            if(e.ctrlKey&&e.key==='d'){e.preventDefault();ThemeManager.toggle();}
        });
    }
};
document.addEventListener('DOMContentLoaded', () => Shortcuts.init());
EOF
c "feat: keyboard shortcuts Ctrl+N, Esc, Ctrl+D" 24 9

sed -i 's|</body>|    <script src="shortcuts.js"></script>\n</body>|' index.html
c "chore: include shortcuts.js" 24 12

mb "feature/shortcuts" 23 15

# === PR #14: Confirm dialog (3 commits) ===
fb "feature/confirm-dialog"

cat > dialog.js << 'EOF'
const Dialog = {
    show(msg, onConfirm) {
        const o=document.createElement('div'); o.className='dialog-overlay';
        o.innerHTML=`<div class="dialog-box"><p class="dialog-message">${msg}</p><div class="dialog-actions"><button class="btn btn-cancel" id="dlgCancel">Hủy</button><button class="btn btn-danger" id="dlgOk">Xác nhận</button></div></div>`;
        document.body.appendChild(o); setTimeout(()=>o.classList.add('show'),10);
        o.querySelector('#dlgOk').onclick=()=>{onConfirm();this.close(o);};
        o.querySelector('#dlgCancel').onclick=()=>this.close(o);
    },
    close(o) { o.classList.remove('show'); setTimeout(()=>o.remove(),300); }
};
EOF
c "feat: confirmation dialog component" 22 9
c "feat: integrate dialog with delete" 22 12

cat >> styles.css << 'EOF'

.dialog-overlay{position:fixed;inset:0;background:rgba(0,0,0,0.6);display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity 0.3s;z-index:2000}
.dialog-overlay.show{opacity:1}
.dialog-box{background:#1a1a3e;border:1px solid rgba(100,255,218,0.2);border-radius:12px;padding:24px;min-width:320px;transform:scale(0.9);transition:transform 0.3s}
.dialog-overlay.show .dialog-box{transform:scale(1)}
.dialog-message{color:#ccd6f6;margin-bottom:20px}
.dialog-actions{display:flex;gap:12px;justify-content:flex-end}
.btn-cancel{background:transparent;border:1px solid #8892b0;color:#8892b0}
.btn-danger{background:rgba(255,82,82,0.8);color:white}
.btn-danger:hover{background:#ff5252}
EOF
c "style: modal dialog with backdrop" 21 10

mb "feature/confirm-dialog" 20 16

# === PR #15: Export/Import (3 commits) ===
fb "feature/export-import"

cat > export.js << 'EOF'
const DataManager = {
    exportJSON() {
        const d={exportedAt:new Date().toISOString(),version:'1.0',tasks:App.tasks};
        const b=new Blob([JSON.stringify(d,null,2)],{type:'application/json'});
        const u=URL.createObjectURL(b); const a=document.createElement('a'); a.href=u;
        a.download=`tasks_${new Date().toISOString().split('T')[0]}.json`; a.click(); URL.revokeObjectURL(u);
        App.notify('Đã xuất JSON!');
    },
    exportCSV() {
        const h=['ID','Title','Description','Priority','Status','Created','Updated'];
        const r=App.tasks.map(t=>[t.id,t.title,t.description,t.priority,t.status,t.createdAt,t.updatedAt]);
        const csv=[h,...r].map(r=>r.map(c=>`"${c}"`).join(',')).join('\n');
        const b=new Blob([csv],{type:'text/csv'}); const u=URL.createObjectURL(b);
        const a=document.createElement('a'); a.href=u; a.download=`tasks_${new Date().toISOString().split('T')[0]}.csv`; a.click(); URL.revokeObjectURL(u);
        App.notify('Đã xuất CSV!');
    },
    importJSON(file) {
        const r=new FileReader(); r.onload=e=>{try{const d=JSON.parse(e.target.result);if(d.tasks){App.tasks=[...App.tasks,...d.tasks];App.saveTasks();App.render();App.notify(`Đã nhập ${d.tasks.length} tasks!`);}}catch(err){App.notify('File không hợp lệ!');}};
        r.readAsText(file);
    }
};
EOF
c "feat: export tasks to JSON" 19 9
c "feat: export tasks to CSV" 19 11
c "feat: import tasks from JSON" 18 10

mb "feature/export-import" 17 15

# === PR #16: Due dates (3 commits) ===
fb "feature/due-dates"

cat > duedate.js << 'EOF'
const DueDate = {
    isOverdue(d) { return d && new Date(d)<new Date(); },
    getDaysLeft(d) { if(!d)return null; return Math.ceil((new Date(d)-new Date())/(1000*60*60*24)); },
    format(d) { if(!d)return''; const days=this.getDaysLeft(d); if(days<0)return`⚠️ Trễ ${Math.abs(days)} ngày`; if(days===0)return'🔴 Hôm nay'; if(days===1)return'🟡 Ngày mai'; if(days<=3)return`🟡 Còn ${days} ngày`; return`🟢 Còn ${days} ngày`; }
};
EOF
c "feat: due date calculation" 16 9
c "feat: overdue detection" 16 11
c "feat: due date display formatting" 15 10

mb "feature/due-dates" 14 16

# === PR #17: Progress bar (3 commits) ===
fb "feature/progress-bar"

cat > progress.js << 'EOF'
const ProgressBar = {
    render() {
        const total=App.tasks.length; if(total===0)return;
        const done=App.tasks.filter(t=>t.status==='done').length;
        const pct=Math.round((done/total)*100);
        const c=document.getElementById('progressBar');
        if(c) c.innerHTML=`<div class="progress-container"><div class="progress-header"><span>Tiến độ</span><span>${pct}%</span></div><div class="progress-track"><div class="progress-fill" style="width:${pct}%"></div></div><div class="progress-details"><span>${done} hoàn thành</span><span>${total-done} còn lại</span></div></div>`;
    }
};
EOF
c "feat: progress bar component" 13 9

cat >> styles.css << 'EOF'

.progress-container{margin-bottom:24px}
.progress-header{display:flex;justify-content:space-between;color:#8892b0;font-size:0.85rem;margin-bottom:8px}
.progress-track{width:100%;height:8px;background:rgba(255,255,255,0.08);border-radius:4px;overflow:hidden}
.progress-fill{height:100%;background:linear-gradient(90deg,#64ffda,#48c9b0);border-radius:4px;transition:width 0.5s ease}
.progress-details{display:flex;justify-content:space-between;color:#8892b0;font-size:0.75rem;margin-top:4px}
EOF
c "style: animated progress bar" 13 12

sed -i 's|<section class="filters">|<div id="progressBar"></div>\n        <section class="filters">|' index.html
c "feat: integrate progress bar in UI" 12 10

mb "feature/progress-bar" 11 16

# === PR #18: Sort tasks (2 commits) ===
fb "feature/sort-tasks"

cat > sort.js << 'EOF'
const SortManager = {
    current: 'newest',
    opts: {
        newest:(a,b)=>new Date(b.createdAt)-new Date(a.createdAt),
        oldest:(a,b)=>new Date(a.createdAt)-new Date(b.createdAt),
        priority:(a,b)=>{const o={high:0,medium:1,low:2};return o[a.priority]-o[b.priority];},
        alpha:(a,b)=>a.title.localeCompare(b.title)
    },
    sort(tasks) { const fn=this.opts[this.current]; return fn?[...tasks].sort(fn):tasks; },
    setSort(s) { this.current=s; App.render(); }
};
EOF
c "feat: sort manager with 4 modes" 10 9
c "feat: sort by priority, date, alpha" 10 12

mb "feature/sort-tasks" 9 15

# === PR #19: Bulk actions (3 commits) ===
fb "feature/bulk-actions"

cat > bulk.js << 'EOF'
const BulkActions = {
    selected: new Set(),
    toggle(id) { this.selected.has(id)?this.selected.delete(id):this.selected.add(id); this.updateUI(); },
    selectAll() { App.tasks.forEach(t=>this.selected.add(t.id)); this.updateUI(); App.render(); },
    deselectAll() { this.selected.clear(); this.updateUI(); App.render(); },
    deleteSelected() { if(!this.selected.size)return; Dialog.show(`Xóa ${this.selected.size} task?`,()=>{App.tasks=App.tasks.filter(t=>!this.selected.has(t.id));this.selected.clear();App.saveTasks();App.render();App.notify('Đã xóa tasks đã chọn');}); },
    completeSelected() { App.tasks.forEach(t=>{if(this.selected.has(t.id)){t.status='done';t.updatedAt=new Date().toISOString();}}); this.selected.clear(); App.saveTasks(); App.render(); },
    updateUI() { const bar=document.getElementById('bulkActionBar'); if(bar){bar.style.display=this.selected.size>0?'flex':'none';} }
};
EOF
c "feat: bulk select functionality" 8 9
c "feat: bulk delete with confirmation" 8 11
c "feat: bulk mark as complete" 7 10

mb "feature/bulk-actions" 6 16

# === PR #20: Stats dashboard (3 commits) ===
fb "feature/stats-dashboard"

cat > stats.js << 'EOF'
const Stats = {
    calculate() {
        const t=App.tasks, total=t.length, done=t.filter(x=>x.status==='done').length, todo=total-done;
        const byP={high:t.filter(x=>x.priority==='high').length,medium:t.filter(x=>x.priority==='medium').length,low:t.filter(x=>x.priority==='low').length};
        const rate=total>0?Math.round((done/total)*100):0;
        const ct=t.filter(x=>x.status==='done'); let avg=0;
        if(ct.length>0){const tt=ct.reduce((s,x)=>s+(new Date(x.updatedAt)-new Date(x.createdAt)),0);avg=Math.round(tt/ct.length/(1000*60*60));}
        return {total,done,todo,byP,rate,avg};
    },
    render() {
        const s=this.calculate(), c=document.getElementById('statsPanel'); if(!c)return;
        c.innerHTML=`<div class="stats-grid"><div class="stat-card"><div class="stat-value">${s.total}</div><div class="stat-label">Tổng Tasks</div></div><div class="stat-card"><div class="stat-value">${s.rate}%</div><div class="stat-label">Hoàn thành</div></div><div class="stat-card"><div class="stat-value">${s.byP.high}</div><div class="stat-label">Ưu tiên cao</div></div><div class="stat-card"><div class="stat-value">${s.avg}h</div><div class="stat-label">TB hoàn thành</div></div></div>`;
    }
};
EOF
c "feat: statistics calculation engine" 5 9

cat >> styles.css << 'EOF'

.stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px}
.stat-card{background:rgba(255,255,255,0.05);border:1px solid rgba(100,255,218,0.1);border-radius:10px;padding:16px;text-align:center;transition:all 0.3s}
.stat-card:hover{border-color:#64ffda;transform:translateY(-2px)}
.stat-value{font-size:1.8rem;font-weight:700;color:#64ffda;margin-bottom:4px}
.stat-label{font-size:0.8rem;color:#8892b0;text-transform:uppercase;letter-spacing:0.5px}
@media(max-width:600px){.stats-grid{grid-template-columns:repeat(2,1fr)}}
EOF
c "style: stats grid with responsive layout" 5 12

sed -i 's|<div id="progressBar">|<div id="statsPanel"></div>\n        <div id="progressBar">|' index.html
c "feat: integrate stats panel in UI" 4 10

mb "feature/stats-dashboard" 3 16

# === PR #21: Responsive (3 commits) ===
fb "feature/responsive"

cat >> styles.css << 'EOF'

@media(max-width:768px){#app{padding:12px}h1{font-size:1.8rem}.task-form{padding:16px}.filters{flex-direction:column;gap:8px}.task-card{padding:12px}.theme-toggle-btn{top:12px;right:12px;width:36px;height:36px}}
@media(max-width:480px){.form-group input,.form-group textarea,.form-group select{font-size:16px}.btn-primary{width:100%}}
EOF
c "style: tablet responsive (768px)" 3 9
c "style: mobile responsive (480px)" 3 11
c "fix: prevent iOS zoom on input focus" 2 9

mb "feature/responsive" 2 15

# === PR #22: Accessibility (2 commits) ===
fb "feature/a11y"

sed -i 's|<section class="task-list"|<section class="task-list" role="list" aria-label="Danh sách tasks"|' index.html
sed -i 's|<form id="addTaskForm">|<form id="addTaskForm" aria-label="Thêm task mới">|' index.html
c "fix(a11y): add ARIA labels" 2 10
c "fix(a11y): improve keyboard navigation" 1 9

mb "feature/a11y" 1 14

# === PR #23: PWA & offline (2 commits) ===
fb "feature/pwa"

cat > sw.js << 'EOF'
const CACHE='task-manager-v1';
const ASSETS=['/','/index.html','/styles.css','/app.js','/drag.js','/theme.js','/categories.js','/shortcuts.js','/dialog.js','/export.js','/duedate.js','/progress.js','/sort.js','/bulk.js','/stats.js'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('fetch',e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
EOF
c "feat: service worker for offline" 1 10

cat > manifest.json << 'EOF'
{"name":"Task Manager","short_name":"TaskMgr","description":"A-SDLC Dashboard Demo","start_url":"/","display":"standalone","background_color":"#0f0f23","theme_color":"#64ffda"}
EOF
c "feat: PWA manifest" 1 11

mb "feature/pwa" 0 9

# === PR #24: Documentation (3 commits) ===
fb "feature/docs"

cat > README.md << 'EOF'
# 📋 Task Manager - A-SDLC Dashboard Demo

> Ứng dụng quản lý công việc, xây dựng để tạo dữ liệu test cho Lab 6: Dashboard Giám sát A-SDLC.

## ✨ Tính năng
- ➕ Thêm, sửa, xóa tasks
- 🔍 Tìm kiếm và lọc theo trạng thái  
- 🏷️ Phân loại theo độ ưu tiên và danh mục
- 🌓 Dark/Light theme
- 📊 Dashboard thống kê
- 📱 Responsive design
- ⌨️ Keyboard shortcuts (Ctrl+N, Ctrl+D, Esc)
- 💾 Export/Import JSON & CSV
- 🔄 Drag & Drop sắp xếp
- 📶 Offline support (PWA)

## 🚀 Sử dụng
```bash
git clone https://github.com/hovikhanh/lab6_Dashboard_A-SDLC.git
cd lab6_Dashboard_A-SDLC
# Mở index.html trong trình duyệt
```

## 📊 Metrics cho Dashboard Lab 6
- **Lead Time for Changes**: Thời gian từ commit đầu tiên đến merge
- **Deployment Frequency**: Số lượng PR merged theo tuần

*Lab 6 - Giáo trình A-SDLC (Chương 9.03)*
EOF
c "docs: comprehensive README" 0 10

cat > CHANGELOG.md << 'EOF'
# Changelog
## [1.0.0] - 2026-08-17
### Added
- Task CRUD with localStorage
- Search, filter, sort
- Dark/Light theme toggle
- Categories, due dates
- Keyboard shortcuts
- Export/Import (JSON/CSV)
- Progress bar, statistics dashboard
- Drag & drop, bulk actions
- Responsive design, accessibility
- PWA with service worker
EOF
c "docs: add CHANGELOG" 0 11

cat > .gitignore << 'EOF'
.DS_Store
Thumbs.db
.vscode/
.idea/
node_modules/
*.log
EOF
c "chore: add .gitignore" 0 12

mb "feature/docs" 0 14

# === PR #25: GitHub Actions workflow (2 commits) ===
fb "feature/metrics-workflow"

mkdir -p .github/workflows
cat > .github/workflows/metrics_collector.yml << 'EOF'
name: Metrics Collector

on:
  pull_request:
    types: [closed]

jobs:
  collect-metrics:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Collect PR Metrics
        run: |
          PR_NUMBER=${{ github.event.pull_request.number }}
          PR_MERGED_AT="${{ github.event.pull_request.merged_at }}"
          PR_TITLE="${{ github.event.pull_request.title }}"
          
          # Get first commit in PR
          FIRST_COMMIT=$(git log --reverse --format="%H" origin/${{ github.event.pull_request.base.ref }}..${{ github.event.pull_request.head.sha }} | head -1)
          COMMIT_TIMESTAMP=$(git show -s --format=%aI $FIRST_COMMIT)
          AUTHOR=$(git show -s --format=%an $FIRST_COMMIT)
          COMMIT_HASH=$(echo $FIRST_COMMIT | cut -c1-7)
          
          echo "📊 Metrics collected:"
          echo "  PR: #$PR_NUMBER - $PR_TITLE"
          echo "  Author: $AUTHOR"
          echo "  First Commit: $COMMIT_HASH at $COMMIT_TIMESTAMP"
          echo "  Merged At: $PR_MERGED_AT"
          
          # Calculate Lead Time
          COMMIT_EPOCH=$(date -d "$COMMIT_TIMESTAMP" +%s)
          MERGE_EPOCH=$(date -d "$PR_MERGED_AT" +%s)
          LEAD_TIME_HOURS=$(( (MERGE_EPOCH - COMMIT_EPOCH) / 3600 ))
          echo "  Lead Time: ${LEAD_TIME_HOURS} hours"

      - name: Send to Google Sheets
        if: env.GOOGLE_SCRIPT_URL != ''
        env:
          GOOGLE_SCRIPT_URL: ${{ secrets.GOOGLE_APPS_SCRIPT_URL }}
        run: |
          curl -s -L "$GOOGLE_SCRIPT_URL" \
            -H "Content-Type: application/json" \
            -d "{
              \"commit_hash\": \"$COMMIT_HASH\",
              \"author\": \"$AUTHOR\",
              \"commit_timestamp\": \"$COMMIT_TIMESTAMP\",
              \"pr_number\": $PR_NUMBER,
              \"pr_merged_timestamp\": \"$PR_MERGED_AT\",
              \"pr_title\": \"$PR_TITLE\",
              \"lead_time_hours\": $LEAD_TIME_HOURS
            }"
          echo "✅ Data sent to Google Sheets"
EOF
c "feat: GitHub Actions metrics collector workflow" 0 13
c "feat: send metrics to Google Sheets via Apps Script" 0 13

mb "feature/metrics-workflow" 0 14

echo ""
echo "================================================================"
echo "🎉 HOÀN TẤT!"
echo "📊 Commits: $COMMIT_COUNT"
echo "🔀 Merges:  $PR_COUNT"
echo "================================================================"
