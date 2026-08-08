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
