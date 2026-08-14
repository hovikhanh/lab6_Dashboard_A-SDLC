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
