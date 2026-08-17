const Categories = {
    list: ['Công việc','Cá nhân','Học tập','Khẩn cấp','Khác'],
    colors: {'Công việc':'#4fc3f7','Cá nhân':'#81c784','Học tập':'#ffb74d','Khẩn cấp':'#e57373','Khác':'#b0bec5'},
    getColor(c) { return this.colors[c]||'#b0bec5'; }
};
