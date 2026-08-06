const ProgressBar = {
    render() {
        const total=App.tasks.length; if(total===0)return;
        const done=App.tasks.filter(t=>t.status==='done').length;
        const pct=Math.round((done/total)*100);
        const c=document.getElementById('progressBar');
        if(c) c.innerHTML=`<div class="progress-container"><div class="progress-header"><span>Tiến độ</span><span>${pct}%</span></div><div class="progress-track"><div class="progress-fill" style="width:${pct}%"></div></div><div class="progress-details"><span>${done} hoàn thành</span><span>${total-done} còn lại</span></div></div>`;
    }
};
