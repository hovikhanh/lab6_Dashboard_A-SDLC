// =============================================================================
// Google Apps Script - Nhận dữ liệu metrics từ GitHub Actions
// =============================================================================
// HƯỚNG DẪN SETUP:
// 1. Tạo Google Sheet mới
// 2. Vào Extensions → Apps Script
// 3. Xóa hết code mặc định, paste toàn bộ code này vào
// 4. Chạy hàm setupSheet() MỘT LẦN (chọn setupSheet → Run)
// 5. Deploy → New deployment → Web app
//    - Execute as: Me
//    - Who has access: Anyone
// 6. Copy URL → Thêm vào GitHub Secrets: GOOGLE_APPS_SCRIPT_URL
// =============================================================================

/**
 * Tạo header cho sheet (chạy 1 lần)
 */
function setupSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // Sheet 1: Raw Data
  let raw = ss.getSheetByName('Raw Data');
  if (!raw) {
    raw = ss.insertSheet('Raw Data');
  }
  raw.getRange('A1:H1').setValues([[
    'commit_hash', 'author', 'commit_timestamp', 
    'pr_number', 'pr_merged_timestamp', 'pr_title',
    'lead_time_hours', 'week_number'
  ]]);
  raw.getRange('A1:H1').setFontWeight('bold').setBackground('#4a86c8').setFontColor('white');
  raw.setFrozenRows(1);
  
  // Sheet 2: Summary (tính toán tự động)
  let summary = ss.getSheetByName('Summary');
  if (!summary) {
    summary = ss.insertSheet('Summary');
  }
  summary.getRange('A1:D1').setValues([['Week', 'Avg Lead Time (hours)', 'PR Count (Deploy Freq)', 'Period']]);
  summary.getRange('A1:D1').setFontWeight('bold').setBackground('#4a86c8').setFontColor('white');
  summary.setFrozenRows(1);
  
  // Xóa sheet mặc định nếu còn
  const defaultSheet = ss.getSheetByName('Sheet1');
  if (defaultSheet && ss.getSheets().length > 1) {
    ss.deleteSheet(defaultSheet);
  }
  
  Logger.log('✅ Setup hoàn tất!');
}

/**
 * Nhận HTTP POST từ GitHub Actions hoặc script
 */
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName('Raw Data');
    
    // Tính week number từ merge timestamp
    const mergeDate = new Date(data.pr_merged_timestamp);
    const weekNum = getWeekNumber(mergeDate);
    
    // Thêm hàng mới
    sheet.appendRow([
      data.commit_hash,
      data.author,
      data.commit_timestamp,
      data.pr_number,
      data.pr_merged_timestamp,
      data.pr_title || '',
      data.lead_time_hours,
      weekNum
    ]);
    
    // Cập nhật Summary
    updateSummary();
    
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'success', week: weekNum }))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'error', message: error.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Nhận HTTP GET (cho test)
 */
function doGet(e) {
  return ContentService
    .createTextOutput(JSON.stringify({ 
      status: 'ok', 
      message: 'Metrics collector is running. Use POST to send data.' 
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * Tính week number của năm
 */
function getWeekNumber(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

/**
 * Cập nhật sheet Summary từ Raw Data
 */
function updateSummary() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const raw = ss.getSheetByName('Raw Data');
  const summary = ss.getSheetByName('Summary');
  
  const data = raw.getDataRange().getValues();
  if (data.length <= 1) return; // Chỉ có header
  
  // Gom nhóm theo tuần
  const weekData = {};
  for (let i = 1; i < data.length; i++) {
    const week = data[i][7]; // week_number column
    const leadTime = data[i][6]; // lead_time_hours column
    const mergeDate = data[i][4]; // pr_merged_timestamp
    
    if (!weekData[week]) {
      weekData[week] = { totalLeadTime: 0, count: 0, dates: [] };
    }
    weekData[week].totalLeadTime += Number(leadTime) || 0;
    weekData[week].count++;
    weekData[week].dates.push(mergeDate);
  }
  
  // Xóa dữ liệu cũ (giữ header)
  const lastRow = summary.getLastRow();
  if (lastRow > 1) {
    summary.getRange(2, 1, lastRow - 1, 4).clear();
  }
  
  // Ghi dữ liệu mới
  const weeks = Object.keys(weekData).sort((a, b) => Number(a) - Number(b));
  const rows = weeks.map(week => {
    const d = weekData[week];
    const avgLeadTime = Math.round((d.totalLeadTime / d.count) * 10) / 10;
    const period = d.dates.length > 0 ? 
      new Date(d.dates[0]).toLocaleDateString('vi-VN') : '';
    return [Number(week), avgLeadTime, d.count, period];
  });
  
  if (rows.length > 0) {
    summary.getRange(2, 1, rows.length, 4).setValues(rows);
  }
}
