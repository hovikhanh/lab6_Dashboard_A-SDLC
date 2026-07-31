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
