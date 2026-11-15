import Foundation

struct PeriodHistoricalEvent: Identifiable {
    let id: String
    let year: String
    let category: String
    let title: String
    let detail: String
}

extension ChopinCreativePeriod {
    var historicalEvents: [PeriodHistoricalEvent] {
        switch id {
        case "childhood":
            [
                event("1815", "波蘭歷史", "波蘭王國成立", "維也納會議建立與俄羅斯帝國共主的波蘭王國。"),
                event("1817", "蕭邦人生", "神童初次出版", "七歲的蕭邦完成並刊行早期波蘭舞曲。"),
                event("1817", "作品誕生", "兩首童年波蘭舞曲", "G 小調與降 B 大調作品留下最早創作軌跡。")
            ]
        case "adolescence":
            [
                event("1820–1822", "波蘭歷史", "政治控制加深", "審查與帝國壓力增加，華沙文化生活仍持續發展。"),
                event("1821", "蕭邦人生", "題獻啟蒙老師", "降 A 大調波蘭舞曲題獻給 Wojciech Żywny。"),
                event("1822", "作品誕生", "和聲語言深化", "升 G 小調作品展現更曖昧的終止與內聲部。")
            ]
        case "warsaw_youth":
            [
                event("1826", "蕭邦人生", "進入華沙音樂院", "在 Józef Elsner 指導下接受作曲訓練。"),
                event("1828–1829", "作品誕生", "青年作品趨向成熟", "音色、低音與戲劇性逐步超越沙龍模型。"),
                event("1829", "波蘭歷史", "起義前夕", "華沙青年知識界的民族意識與政治張力升高。")
            ]
        case "departure":
            [
                event("1830.11.02", "蕭邦人生", "離開華沙", "蕭邦出發前往維也納，之後未再返回故鄉。"),
                event("1830.11.29", "波蘭歷史", "十一月起義", "華沙爆發反抗俄羅斯統治的武裝起義。"),
                event("1831", "作品誕生", "華麗大波蘭舞曲", "面向歐洲音樂廳的 brillante 風格成為轉折橋梁。")
            ]
        case "paris_formation":
            [
                event("1832", "蕭邦人生", "巴黎立足", "公開演出與貴族學生使他的職業生活逐步穩定。"),
                event("1834–1835", "作品誕生", "補寫平靜的行板", "以夜曲式序奏連結較早的華麗波蘭舞曲。"),
                event("1835", "作品誕生", "Op. 26 開啟新篇", "波蘭舞曲朝史詩—戲劇性鋼琴詩轉化。")
            ]
        case "mature_paris":
            [
                event("1838–1839", "蕭邦人生", "馬約卡與諾昂", "旅行、健康困境與後續安定創作環境交錯。"),
                event("1838–1843", "作品誕生", "成熟波蘭舞曲群", "Op. 40、44、53 以不同方式處理民族記憶。"),
                event("1843", "作品接受", "英雄形象形成", "Op. 53 後來以〈英雄〉通稱流傳，並非作曲家原題。")
            ]
        case "late":
            [
                event("1846", "波蘭歷史", "克拉科夫起義", "短暫起義失敗，列強統治與社會矛盾交疊。"),
                event("1845–1846", "蕭邦人生", "健康與關係惡化", "晚年生活的不穩定與創作上的高度凝鍊並存。"),
                event("1846", "作品誕生", "波蘭幻想曲 Op. 61", "舞曲節奏被內化為片段、回憶與自由變形。")
            ]
        default:
            []
        }
    }

    var sourceNote: String {
        "年代與作品資料主要依波蘭國立蕭邦研究院作品目錄及生平年表整理；心境段落為根據書信、時代背景與音樂特徵所作的詮釋性推測。"
    }

    private func event(
        _ year: String,
        _ category: String,
        _ title: String,
        _ detail: String
    ) -> PeriodHistoricalEvent {
        PeriodHistoricalEvent(
            id: "\(id)-\(year)-\(title)",
            year: year,
            category: category,
            title: title,
            detail: detail
        )
    }
}
