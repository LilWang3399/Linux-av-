# Linux 系統清理與病毒掃描整合腳本

![Shell Script](https://img.shields.io/badge/Shell_Script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![ClamAV](https://img.shields.io/badge/ClamAV-%2300599C.svg?style=for-the-badge&logo=clamav&logoColor=white)

## 📜 腳本簡介
專為Linux系統設計的智能維護工具，整合系統垃圾清理與病毒掃描雙重功能，適用於以下場景：
- 🗑️ 定期系統維護
- 🛡️ 安全威脅排查
- 📉 磁碟空間優化
- 🔍 可疑活動分析

## 🚀 主要功能

### 🧹 系統清理模組
| 功能類別       | 具體操作                              | 安全機制                  |
|----------------|-------------------------------------|--------------------------|
| 套件管理       | `apt` 自動清理舊版本與緩存            | 保留必要依賴             |
| 日誌管理       | 自動輪替+刪除7天前日誌                | 保留系統關鍵日誌         |
| 臨時文件       | 清除`/tmp`和`/var/tmp`內容            | 不影響運行中進程         |
| 用戶空間       | 清理`.cache`和`.thumbnails`目錄       | 保留用戶主目錄結構       |

### 🛠️ 使用方法
```bash
# 基礎執行（需要root權限）
sudo bash cleanup_antivirus.sh

# 進階用法（結合其他工具）
watch -n 3600 cleanup_antivirus.sh  # 每小時自動執行
```
### 🔬 病毒掃描模組
```bash
# 特徵庫更新機制
freshclam --quiet  # 靜默模式更新
# 掃描指令範例
clamscan -r -i --exclude-dir=/proc /
```

### ⚠️ 重要注意事項
資源消耗：

- 首次運行將安裝ClamAV（約佔500MB空間）

- 全盤掃描時CPU使用率可能達70-90%

掃描建議：
- 推薦掃描時段：`22:00 - 06:00`
- 最小化終端操作避免干擾
- SSD用戶建議啟用`ionice`優先級調整

結果解讀：

✅ SCAN_RESULT=0：系統安全

🟡 SCAN_RESULT=1：發現威脅（查看日誌/var/log/clean_scan_*.log）

🔴 SCAN_RESULT>=2：掃描過程發生錯誤
