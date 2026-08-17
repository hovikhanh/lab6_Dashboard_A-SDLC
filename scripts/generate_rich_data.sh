#!/bin/bash
# =============================================================================
# Script: generate_rich_data.sh
# Sinh dữ liệu metrics đa dạng và phong phú cho Dashboard Lab 6
#
# Kịch bản: Một team 5 người phát triển phần mềm trong 12 tuần
# - Tuần 1-4:  Team mới, lead time cao, ít PR
# - Tuần 5-8:  Quen dần, lead time giảm, nhiều PR hơn
# - Tuần 9-12: Hiệu quả cao, lead time thấp, deploy thường xuyên
#
# Sử dụng:
#   ./scripts/generate_rich_data.sh <GOOGLE_APPS_SCRIPT_URL>
# =============================================================================

set -e

SCRIPT_URL="$1"

if [ -z "$SCRIPT_URL" ]; then
    echo "❌ Thiếu URL Google Apps Script!"
    echo "Cách dùng: ./scripts/generate_rich_data.sh <URL>"
    exit 1
fi

# === CẤU HÌNH ===
AUTHORS=("Vika" "Minh Tuan" "Thu Hà" "Quốc Anh" "Linh Chi")
FEATURE_TYPES=(
    "feat" "feat" "feat" "feat"   # 40% features
    "fix" "fix" "fix"             # 30% bugfixes  
    "refactor" "refactor"         # 20% refactor
    "docs"                        # 10% docs
)
FEATURE_NAMES=(
    # Features
    "user-authentication" "payment-gateway" "dashboard-charts" "notification-system"
    "file-upload" "search-api" "report-generator" "user-profile"
    "email-templates" "api-rate-limiter" "caching-layer" "webhook-handler"
    "audit-logging" "role-permissions" "data-export" "analytics-tracker"
    "onboarding-flow" "password-reset" "multi-language" "dark-mode"
    "real-time-sync" "batch-processing" "error-boundary" "lazy-loading"
    # Fixes
    "login-timeout" "memory-leak" "race-condition" "null-pointer"
    "cors-headers" "timezone-bug" "pagination-off-by-one" "encoding-issue"
    "session-expiry" "cache-invalidation" "deadlock-fix" "retry-logic"
    # Refactors
    "database-migration" "api-versioning" "code-splitting" "test-coverage"
    "dependency-update" "config-refactor" "logging-overhaul" "ci-pipeline"
    # Docs
    "api-documentation" "setup-guide" "changelog-update" "architecture-diagram"
)

PR_COUNT=0
TOTAL=0

send_data() {
    local commit_hash="$1"
    local author="$2"
    local commit_ts="$3"
    local pr_num="$4"
    local merge_ts="$5"
    local pr_title="$6"
    local lead_time="$7"
    
    TOTAL=$((TOTAL + 1))
    
    echo "  📤 PR #${pr_num}: ${pr_title} (by ${author}, ${lead_time}h)"
    
    curl -s -L -o /dev/null "$SCRIPT_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"commit_hash\": \"${commit_hash}\",
            \"author\": \"${author}\",
            \"commit_timestamp\": \"${commit_ts}\",
            \"pr_number\": ${pr_num},
            \"pr_merged_timestamp\": \"${merge_ts}\",
            \"pr_title\": \"${pr_title}\",
            \"lead_time_hours\": ${lead_time}
        }" 2>/dev/null
    
    # Delay tránh rate limit
    sleep 0.5
}

# Hàm tạo random hash
rand_hash() {
    cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 7 | head -n 1
}

# Hàm random trong khoảng [min, max]
rand_range() {
    echo $(( RANDOM % ($2 - $1 + 1) + $1 ))
}

# Hàm chọn random từ array
rand_pick() {
    local arr=("$@")
    echo "${arr[RANDOM % ${#arr[@]}]}"
}

echo "🚀 Sinh dữ liệu metrics phong phú cho Dashboard"
echo "📊 Kịch bản: Team 5 người, 12 tuần phát triển"
echo "================================================"
echo ""

# =============================================================================
# GIAI ĐOẠN 1: TUẦN 1-4 (Khởi đầu - Lead time cao, ít PR)
# 84-56 ngày trước
# Đặc điểm: Team mới, quy trình chưa rõ, review lâu
# =============================================================================
echo "📅 GIAI ĐOẠN 1: Tuần 1-4 (Khởi đầu)"
echo "   Đặc điểm: Lead time 24-72h, 2-3 PR/tuần"
echo "-------------------------------------------"

# Tuần 1: 2 PRs (rất chậm)
for i in 1 2; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 81 84)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 48 72)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 2: 3 PRs
for i in 1 2 3; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 74 80)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 36 60)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 3: 3 PRs
for i in 1 2 3; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 67 73)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 30 55)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 4: 3 PRs (bắt đầu cải thiện)
for i in 1 2 3; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 60 66)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 24 48)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

echo ""

# =============================================================================
# GIAI ĐOẠN 2: TUẦN 5-8 (Trưởng thành - Lead time giảm, nhiều PR hơn)
# 56-28 ngày trước
# Đặc điểm: Team quen, AI hỗ trợ, review nhanh hơn
# =============================================================================
echo "📅 GIAI ĐOẠN 2: Tuần 5-8 (Trưởng thành)"
echo "   Đặc điểm: Lead time 12-36h, 4-5 PR/tuần"
echo "-------------------------------------------"

# Tuần 5: 4 PRs
for i in 1 2 3 4; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 53 59)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 18 36)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 6: 5 PRs
for i in 1 2 3 4 5; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 46 52)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 14 30)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 7: 5 PRs + 1 incident (lead time rất cao = hotfix)
for i in 1 2 3 4 5; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 39 45)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 12 28)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Incident PR (hotfix nhanh!)
PR_COUNT=$((PR_COUNT + 1))
HASH=$(rand_hash)
DAYS_AGO=41
COMMIT_TS=$(date -d "$DAYS_AGO days ago 2 hours" --iso-8601=seconds)
MERGE_TS=$(date -d "$DAYS_AGO days ago 4 hours" --iso-8601=seconds)
send_data "$HASH" "Quốc Anh" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "hotfix/production-outage" "2"

# Tuần 8: 5 PRs
for i in 1 2 3 4 5; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 32 38)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 10 24)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO - LEAD / 24)) days ago $((HOUR + LEAD % 24)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

echo ""

# =============================================================================
# GIAI ĐOẠN 3: TUẦN 9-12 (Hiệu suất cao - Lead time thấp, deploy liên tục)
# 28-0 ngày trước
# Đặc điểm: A-SDLC mature, CI/CD tự động, AI code review
# =============================================================================
echo "📅 GIAI ĐOẠN 3: Tuần 9-12 (Hiệu suất cao)"
echo "   Đặc điểm: Lead time 4-16h, 6-8 PR/tuần"
echo "-------------------------------------------"

# Tuần 9: 6 PRs
for i in 1 2 3 4 5 6; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 25 31)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 6 16)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO)) days ago $((HOUR + LEAD)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 10: 7 PRs  
for i in 1 2 3 4 5 6 7; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 18 24)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 4 14)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO)) days ago $((HOUR + LEAD)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 11: 8 PRs (peak performance)
for i in 1 2 3 4 5 6 7 8; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 11 17)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 3 12)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO)) days ago $((HOUR + LEAD)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

# Tuần 12: 8 PRs (duy trì hiệu suất)
for i in 1 2 3 4 5 6 7 8; do
    PR_COUNT=$((PR_COUNT + 1))
    AUTHOR=$(rand_pick "${AUTHORS[@]}")
    TYPE=$(rand_pick "${FEATURE_TYPES[@]}")
    NAME=$(rand_pick "${FEATURE_NAMES[@]}")
    HASH=$(rand_hash)
    DAYS_AGO=$(rand_range 1 10)
    HOUR=$(rand_range 8 17)
    LEAD=$(rand_range 2 10)
    
    COMMIT_TS=$(date -d "$DAYS_AGO days ago $HOUR hours" --iso-8601=seconds)
    MERGE_TS=$(date -d "$((DAYS_AGO)) days ago $((HOUR + LEAD)) hours" --iso-8601=seconds)
    
    send_data "$HASH" "$AUTHOR" "$COMMIT_TS" "$PR_COUNT" "$MERGE_TS" "${TYPE}/${NAME}" "$LEAD"
done

echo ""
echo "================================================"
echo "🎉 HOÀN TẤT!"
echo "📊 Tổng PR đã gửi: $PR_COUNT"
echo ""
echo "📈 Kịch bản dữ liệu:"
echo "   Giai đoạn 1 (Tuần 1-4):  11 PRs, Lead time 24-72h"
echo "   Giai đoạn 2 (Tuần 5-8):  21 PRs, Lead time 10-36h"  
echo "   Giai đoạn 3 (Tuần 9-12): 29 PRs, Lead time 2-16h"
echo ""
echo "📊 Xu hướng mong đợi trên Dashboard:"
echo "   📉 Lead Time: Giảm dần (72h → 6h)"
echo "   📈 Deploy Frequency: Tăng dần (2/tuần → 8/tuần)"
echo "   👥 5 tác giả khác nhau"
echo "   🏷️  4 loại PR (feat/fix/refactor/docs)"
echo "   🔥 1 hotfix incident (lead time 2h)"
echo ""
echo "🔗 Kiểm tra Google Sheet và tạo Dashboard Looker Studio!"
