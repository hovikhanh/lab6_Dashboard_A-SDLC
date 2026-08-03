const DueDate = {
    isOverdue(d) { return d && new Date(d)<new Date(); },
    getDaysLeft(d) { if(!d)return null; return Math.ceil((new Date(d)-new Date())/(1000*60*60*24)); },
    format(d) { if(!d)return''; const days=this.getDaysLeft(d); if(days<0)return`⚠️ Trễ ${Math.abs(days)} ngày`; if(days===0)return'🔴 Hôm nay'; if(days===1)return'🟡 Ngày mai'; if(days<=3)return`🟡 Còn ${days} ngày`; return`🟢 Còn ${days} ngày`; }
};
