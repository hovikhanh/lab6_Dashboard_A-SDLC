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
