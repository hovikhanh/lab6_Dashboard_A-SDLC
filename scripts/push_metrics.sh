#!/bin/bash
# =============================================================================
# Script: push_metrics.sh
# Trích xuất dữ liệu merge commits từ git log → đẩy lên Google Sheet
# 
# Sử dụng:
#   ./scripts/push_metrics.sh <GOOGLE_APPS_SCRIPT_URL>
#
# Ví dụ:
#   ./scripts/push_metrics.sh "https://script.google.com/macros/s/ABC.../exec"
# =============================================================================

set -e

SCRIPT_URL="$1"

if [ -z "$SCRIPT_URL" ]; then
    echo "❌ Thiếu URL Google Apps Script!"
    echo ""
    echo "Cách sử dụng:"
    echo "  ./scripts/push_metrics.sh <GOOGLE_APPS_SCRIPT_URL>"
    echo ""
    echo "Hướng dẫn lấy URL:"
    echo "  1. Mở Google Sheet → Extensions → Apps Script"
    echo "  2. Paste code từ google_apps_script/code.gs"
    echo "  3. Chạy setupSheet() một lần"
    echo "  4. Deploy → New deployment → Web app"
    echo "  5. Copy URL và dùng làm tham số"
    exit 1
fi

echo "📊 Trích xuất dữ liệu từ git log..."
echo "================================"

# Lấy tất cả merge commits với parent info
PR_NUM=0
SUCCESS=0
FAIL=0

git log --merges --format='%H|%aI|%s' --reverse | while IFS='|' read MERGE_HASH MERGE_DATE MSG; do
    PR_NUM=$((PR_NUM + 1))
    
    # Trích xuất PR number từ commit message "Merge branch '...' into main (#N)"
    EXTRACTED_PR=$(echo "$MSG" | grep -oP '#\K[0-9]+' || echo "$PR_NUM")
    
    # Trích xuất branch name
    BRANCH=$(echo "$MSG" | grep -oP "Merge branch '\K[^']+" || echo "unknown")
    
    # Lấy commit đầu tiên trong branch (parent thứ 2 của merge commit)
    # Merge commit có 2 parents: parent1 = main, parent2 = feature branch
    BRANCH_TIP=$(git rev-parse "${MERGE_HASH}^2" 2>/dev/null)
    MAIN_PARENT=$(git rev-parse "${MERGE_HASH}^1" 2>/dev/null)
    
    if [ -n "$BRANCH_TIP" ] && [ -n "$MAIN_PARENT" ]; then
        # Lấy commit đầu tiên trên branch (sau khi rẽ từ main)
        FIRST_COMMIT=$(git log --reverse --format='%H' "${MAIN_PARENT}..${BRANCH_TIP}" 2>/dev/null | head -1)
        
        if [ -n "$FIRST_COMMIT" ]; then
            COMMIT_HASH=$(echo "$FIRST_COMMIT" | cut -c1-7)
            COMMIT_DATE=$(git show -s --format='%aI' "$FIRST_COMMIT")
            AUTHOR=$(git show -s --format='%an' "$FIRST_COMMIT")
        else
            COMMIT_HASH=$(echo "$BRANCH_TIP" | cut -c1-7)
            COMMIT_DATE=$(git show -s --format='%aI' "$BRANCH_TIP")
            AUTHOR=$(git show -s --format='%an' "$BRANCH_TIP")
        fi
    else
        COMMIT_HASH="unknown"
        COMMIT_DATE="$MERGE_DATE"
        AUTHOR="unknown"
    fi
    
    # Tính Lead Time (giờ)
    COMMIT_EPOCH=$(date -d "$COMMIT_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$COMMIT_DATE" +%s 2>/dev/null || echo 0)
    MERGE_EPOCH=$(date -d "$MERGE_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$MERGE_DATE" +%s 2>/dev/null || echo 0)
    
    if [ "$COMMIT_EPOCH" -gt 0 ] && [ "$MERGE_EPOCH" -gt 0 ]; then
        LEAD_TIME=$(( (MERGE_EPOCH - COMMIT_EPOCH) / 3600 ))
    else
        LEAD_TIME=0
    fi
    
    echo "  PR #${EXTRACTED_PR}: ${BRANCH}"
    echo "    Commit: ${COMMIT_HASH} (${COMMIT_DATE})"
    echo "    Merged: ${MERGE_DATE}"
    echo "    Lead Time: ${LEAD_TIME}h"
    
    # Gửi đến Google Sheet
    RESPONSE=$(curl -s -L -w "\n%{http_code}" "$SCRIPT_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"commit_hash\": \"${COMMIT_HASH}\",
            \"author\": \"${AUTHOR}\",
            \"commit_timestamp\": \"${COMMIT_DATE}\",
            \"pr_number\": ${EXTRACTED_PR},
            \"pr_merged_timestamp\": \"${MERGE_DATE}\",
            \"pr_title\": \"${BRANCH}\",
            \"lead_time_hours\": ${LEAD_TIME}
        }" 2>/dev/null)
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | head -1)
    
    if echo "$HTTP_CODE" | grep -qE "^2|^3"; then
        echo "    ✅ Sent successfully"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "    ❌ Failed (HTTP $HTTP_CODE): $BODY"
        FAIL=$((FAIL + 1))
    fi
    echo ""
    
    # Delay nhỏ để tránh rate limit
    sleep 1
done

echo "================================"
echo "🎉 Hoàn tất!"
echo "✅ Thành công: xem Google Sheet để kiểm tra"
echo ""
echo "📋 Bước tiếp theo:"
echo "   1. Mở Google Sheet kiểm tra dữ liệu"
echo "   2. Vào Google Looker Studio → Create → Data source: Google Sheets"
echo "   3. Tạo dashboard với Line Chart (Lead Time) và Bar Chart (Deploy Freq)"
