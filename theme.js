const ThemeManager = {
    current: localStorage.getItem('theme')||'dark',
    init() { this.apply(this.current); document.getElementById('themeToggle')?.addEventListener('click',()=>this.toggle()); },
    toggle() { this.current=this.current==='dark'?'light':'dark'; this.apply(this.current); localStorage.setItem('theme',this.current); },
    apply(t) { document.documentElement.setAttribute('data-theme',t); const b=document.getElementById('themeToggle'); if(b) b.textContent=t==='dark'?'☀️':'🌙'; }
};
document.addEventListener('DOMContentLoaded', () => ThemeManager.init());
