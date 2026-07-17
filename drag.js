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
