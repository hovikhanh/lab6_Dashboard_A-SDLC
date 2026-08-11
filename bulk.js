const BulkActions = {
    selected: new Set(),
    toggle(id) { this.selected.has(id)?this.selected.delete(id):this.selected.add(id); this.updateUI(); },
    selectAll() { App.tasks.forEach(t=>this.selected.add(t.id)); this.updateUI(); App.render(); },
    deselectAll() { this.selected.clear(); this.updateUI(); App.render(); },
    deleteSelected() { if(!this.selected.size)return; Dialog.show(`Xóa ${this.selected.size} task?`,()=>{App.tasks=App.tasks.filter(t=>!this.selected.has(t.id));this.selected.clear();App.saveTasks();App.render();App.notify('Đã xóa tasks đã chọn');}); },
    completeSelected() { App.tasks.forEach(t=>{if(this.selected.has(t.id)){t.status='done';t.updatedAt=new Date().toISOString();}}); this.selected.clear(); App.saveTasks(); App.render(); },
    updateUI() { const bar=document.getElementById('bulkActionBar'); if(bar){bar.style.display=this.selected.size>0?'flex':'none';} }
};
