import Foundation

struct ChopinCreativePeriod: Identifiable {
    let id: String
    let years: String
    let title: String
    let subtitle: String
    let historicalContext: String
    let creativeContext: String
    let inferredMindset: String
    let chapterIDs: [String]

    var works: [PolonaiseChapter] {
        chapterIDs.compactMap { id in
            PolonaiseCatalog.chapters.first { $0.id == id }
        }
    }
}

enum ChopinPeriodCatalog {
    static let periods: [ChopinCreativePeriod] = [
        ChopinCreativePeriod(
            id: "childhood",
            years: "1817",
            title: "童年初聲",
            subtitle: "在華沙沙龍語彙中，第一次寫下自己的名字",
            historicalContext: "維也納會議後，華沙位於由俄羅斯皇帝兼任國王的「波蘭王國」之內。形式上保有憲法、議會與波蘭文化機構，政治自主卻受到帝國權力限制。波蘭舞曲既是社交禮儀，也承載著地方文化身份。",
            creativeContext: "七歲的蕭邦以當時華沙常見的沙龍波蘭舞曲為模型。兩首作品仍有清楚對稱的句法與古典終止，但旋律的自然呼吸、裝飾音的分寸與段落安排，已顯示他不只是照抄格式，而在學習如何讓鋼琴說話。",
            inferredMindset: "可合理推測，此時的核心感受更接近好奇、模仿與獲得肯定的喜悅，而不是後世常加諸蕭邦的「亡國悲情」。他尚是受到家庭與華沙文化圈保護的神童；音樂中的端正與明亮，首先來自兒童對成熟世界的敏銳觀察。",
            chapterIDs: ["13", "14"]
        ),
        ChopinCreativePeriod(
            id: "adolescence",
            years: "1821–1822",
            title: "少年養成",
            subtitle: "從獻禮小品走向個人和聲色彩",
            historicalContext: "波蘭王國的自由空間逐步收緊，審查與政治壓力加深；另一方面，華沙的學校、劇院、出版與私人沙龍仍維持活躍文化生活。民族文化的保存，往往發生在教育與日常藝術活動之中。",
            creativeContext: "題獻給啟蒙老師 Żywny 的降 A 大調作品，保留親密的獻禮性格；隔年的升 G 小調作品則以較少見的調性、延宕終止與內聲部移動增加陰影。蕭邦開始把波蘭舞曲從「合宜的格式」變成可以容納私人語氣的小型作品。",
            inferredMindset: "作品讓人感到少年作曲家一面尊敬師承，一面迫切尋找獨特聲音。這是依據作品風格做出的詮釋，而非日記式證據；較可信的說法是，他的自信正在增加，對和聲曖昧與旋律呼吸的興趣也愈來愈明確。",
            chapterIDs: ["15", "16"]
        ),
        ChopinCreativePeriod(
            id: "warsaw_youth",
            years: "1825–1829",
            title: "華沙青年期",
            subtitle: "學院訓練、城市舞台與成熟語言的前夜",
            historicalContext: "1820 年代後期，華沙知識界的民族意識與反帝國情緒逐漸升高。蕭邦就讀華沙音樂院、往來劇院與文化沙龍；政治緊張尚未全面爆發，但年輕世代已活在改革期待、審查與愛國思想交錯的環境。",
            creativeContext: "Op. 71 三首與兩首身後出版作品顯示技法快速成熟：低音不再只負責節拍，調性與音域開始承擔戲劇功能，歌唱段落也逐漸成為與外在禮儀對抗的內在聲音。波蘭舞曲仍屬沙龍傳統，卻已接近後來的心理敘事。",
            inferredMindset: "這些作品可被理解為雄心與不安並存：年輕作曲家準備走向歐洲舞台，仍深繫華沙的人際與文化生活。〈告別〉等通稱不能當作確定劇情；更穩妥的推測，是他已開始感受到成長必然伴隨離開與失去。",
            chapterIDs: ["10", "17", "11", "12", "18"]
        ),
        ChopinCreativePeriod(
            id: "departure",
            years: "1830–1831",
            title: "離鄉與起義",
            subtitle: "旅程突然變成無法回返的流亡",
            historicalContext: "蕭邦於 1830 年 11 月 2 日離開華沙；四週後，十一月起義爆發。起義在 1831 年失敗，俄羅斯進一步壓縮波蘭王國自治，大批政治與文化人士流亡西歐，形成「大流亡」。蕭邦也在這條歷史斷裂線上轉往巴黎。",
            creativeContext: "降 E 大調《華麗大波蘭舞曲》保留青年作曲家面向公共舞台的 brillante 炫技傳統：鋼琴與想像中的樂團對話，速度、跳躍與裝飾被穩固舞曲節奏統攝。它位於華沙養成與巴黎成熟之間，是身分轉換最清楚的橋梁。",
            inferredMindset: "書信與旅行紀錄支持他曾強烈想返鄉、因無法參與起義而焦灼。若把這種情緒直接等同每個音符仍會過度簡化；較謹慎的理解是，作品原有的舞台自信，在歷史劇變後被聽見時，多了一層失根與證明自己的壓力。",
            chapterIDs: ["09"]
        ),
        ChopinCreativePeriod(
            id: "paris_formation",
            years: "1834–1835",
            title: "巴黎立足",
            subtitle: "從演奏家光芒轉向史詩性的鋼琴敘事",
            historicalContext: "巴黎成為波蘭流亡者的重要中心。離散社群以報刊、沙龍、紀念活動與政治組織延續國族文化；蕭邦則在法國首都建立教學、出版與演奏網絡，生活穩定下來，故鄉卻已成為不能自由返回的遠方。",
            creativeContext: "約 1834–35 年補寫的〈平靜的行板〉，以夜曲式私密歌唱銜接較早的華麗波蘭舞曲。同期 Op. 26 兩首則被研究者視為類型轉折：波蘭舞曲不再是社交舞蹈的精緻改編，而成為帶有衝突、暗色和聲與長篇戲劇弧線的「史詩—戲劇詩」。",
            inferredMindset: "可推測他正處於雙重狀態：職業上逐漸自信，情感上仍面對離散與記憶的持續拉扯。〈行板〉的安定不必解讀為真正平靜，Op. 26 的陰影也不等同單一政治密碼；兩者並置，更像私人自我與公共身份同時成形。",
            chapterIDs: ["08", "01", "02"]
        ),
        ChopinCreativePeriod(
            id: "mature_paris",
            years: "1838–1843",
            title: "成熟與民族記憶",
            subtitle: "波蘭舞曲成為公共象徵與私人回憶的交會",
            historicalContext: "波蘭仍被俄羅斯、普魯士與奧地利分割，巴黎流亡社群對復國道路也有不同主張。1838–39 年蕭邦與喬治・桑旅居馬約卡，健康與創作環境一度惡化；返法後，他在諾昂與巴黎完成多部大型鋼琴作品。",
            creativeContext: "Op. 40 從明亮的紀念碑姿態轉向 C 小調的哀悼重量；Op. 44 把波蘭舞曲與瑪祖卡置於同一結構，讓公共歷史與鄉土記憶互相映照；Op. 53 則以長距離能量控制建立後世所稱的「英雄性」。這些稱號不是作曲家親題，應視為接受史的一部分。",
            inferredMindset: "作品可讓人聯想到尊嚴、鄉愁、抵抗與自我要求，但不能據此診斷蕭邦的內心。較可靠的推測是：他已能把離散經驗轉化成高度控制的形式，使激情不靠口號，而透過節奏、音色與結構累積獲得力量。",
            chapterIDs: ["03", "04", "05", "06"]
        ),
        ChopinCreativePeriod(
            id: "late",
            years: "1845–1846",
            title: "晚期：記憶的重組",
            subtitle: "在破碎形式中重新尋找波蘭舞曲",
            historicalContext: "1846 年克拉科夫起義迅速失敗，同年加利西亞爆發農民暴動，波蘭社會內部矛盾與列強統治交疊。歐洲革命前夕的政治氣氛日益緊張；蕭邦的健康惡化，與喬治・桑的關係也接近決裂。",
            creativeContext: "《波蘭幻想曲》Op. 61 不再以整齊舞步直接宣告身份，而由片段、停頓、調性遠遊與逐步變形建立形式。波蘭舞曲節奏像記憶般時隱時現，最終才凝聚成精神性的光亮；這是類型被徹底內化後的晚期語言。",
            inferredMindset: "作品常被聽成告別或精神超越，但這些仍屬詮釋。從音樂可較有把握地說：蕭邦不再追求早期的直接華麗，也不滿足於中期的英雄姿態；他似乎更關心記憶如何破碎、重組，以及身份如何在不確定中被重新確認。",
            chapterIDs: ["07"]
        )
    ]
}
