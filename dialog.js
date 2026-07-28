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
