#!/bin/bash

# 綜合清理與殺毒腳本
# 需使用root權限執行

# 檢查root權限
if [ "$(id -u)" != "0" ]; then
    echo "請使用sudo或root權限執行此腳本"
    exit 1
fi

# 定義日誌文件位置
LOG_FILE="/var/log/clean_scan_$(date +%Y%m%d%H%M).log"

# 函數：記錄日誌與輸出信息
log_and_echo() {
    echo "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 系統清理部分
system_cleanup() {
    log_and_echo "=== 開始系統清理 ==="

    # 清理套件缓存
    log_and_echo "清理APT缓存..."
    apt-get autoremove -y >> "$LOG_FILE" 2>&1
    apt-get autoclean -y >> "$LOG_FILE" 2>&1
    apt-get clean -y >> "$LOG_FILE" 2>&1

    # 清理日誌文件（保留最近7天）
    log_and_echo "輪替日誌文件..."
    journalctl --vacuum-time=7d >> "$LOG_FILE" 2>&1
    find /var/log -type f -name "*.gz" -delete >> "$LOG_FILE" 2>&1
    find /var/log -type f -name "*.old" -delete >> "$LOG_FILE" 2>&1

    # 清理臨時文件
    log_and_echo "清理臨時文件..."
    rm -rf /tmp/* /var/tmp/* >> "$LOG_FILE" 2>&1

    # 清理用戶缓存（保留各用戶主目錄）
    log_and_echo "清理用戶缓存..."
    for user_dir in /home/*; do
        if [ -d "$user_dir" ]; then
            rm -rf "$user_dir/.cache/*" "$user_dir/.thumbnails/*" >> "$LOG_FILE" 2>&1
        fi
    done

    log_and_echo "=== 系統清理完成 ==="
}

# 病毒掃描部分
virus_scan() {
    log_and_echo "=== 開始病毒掃描 ==="

    # 檢查並安裝ClamAV
    if ! command -v freshclam &> /dev/null; then
        log_and_echo "安裝ClamAV..."
        apt-get install -y clamav clamav-daemon >> "$LOG_FILE" 2>&1
        systemctl stop clamav-freshclam
        freshclam >> "$LOG_FILE" 2>&1
        systemctl start clamav-freshclam
    fi

    # 更新病毒庫
    log_and_echo "更新病毒定義檔..."
    freshclam --quiet >> "$LOG_FILE" 2>&1

    # 設定掃描路徑（可自行修改）
    SCAN_PATH="/"
    
    # 排除目錄（根據需要調整）
    EXCLUDE_DIRS="--exclude-dir=/proc --exclude-dir=/sys --exclude-dir=/dev"

    # 執行掃描
    log_and_echo "開始全系統掃描（可能需要較長時間）..."
    clamscan -r -i $EXCLUDE_DIRS "$SCAN_PATH" >> "$LOG_FILE" 2>&1

    SCAN_RESULT=$?
    if [ $SCAN_RESULT -eq 0 ]; then
        log_and_echo "掃描完成，未發現惡意軟體"
    elif [ $SCAN_RESULT -eq 1 ]; then
        log_and_echo "警告：發現可疑文件！請檢查日誌：$LOG_FILE"
    else
        log_and_echo "掃描異常結束，錯誤碼：$SCAN_RESULT"
    fi

    log_and_echo "=== 病毒掃描完成 ==="
}

# 執行清理與掃描
system_cleanup
virus_scan

log_and_echo "操作完成！詳細日誌請查看：$LOG_FILE"
