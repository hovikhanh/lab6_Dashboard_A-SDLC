const CACHE='task-manager-v1';
const ASSETS=['/','/index.html','/styles.css','/app.js','/drag.js','/theme.js','/categories.js','/shortcuts.js','/dialog.js','/export.js','/duedate.js','/progress.js','/sort.js','/bulk.js','/stats.js'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('fetch',e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
