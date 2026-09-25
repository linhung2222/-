//
//  Models.swift
//  五行拳
//
//  五行拳核心領域資料模型模組
//  定義五行元素屬性、拳法招式、生剋相生相剋邏輯、玩家狀態、單回合結算與歷史戰報紀錄
//

import SwiftUI

// MARK: - 五行元素定義

/// 五行元素核心列舉（金、木、水、火、土）
/// 遵循 String、CaseIterable 與 Identifiable 協定，提供 rawValue 作為辨識字串
enum FiveElement: String, CaseIterable, Identifiable {
    /// 金元素：形意劈拳，性堅剛肅殺
    case metal = "金"
    /// 木元素：形意崩拳，性生發條達
    case wood = "木"
    /// 水元素：形意鑽拳，性潤下靈動
    case water = "水"
    /// 火元素：形意炮拳，性炎上烈焰
    case fire = "火"
    /// 土元素：形意橫拳，性承載孕育
    case earth = "土"
    
    /// 唯一識別碼，直接使用元素的字串名稱
    var id: String { rawValue }
    
    /// 對應之形意五行拳招式名稱
    /// 金對應劈拳、木對應崩拳、水對應鑽拳、火對應炮拳、土對應橫拳
    var attackName: String {
        switch self {
        case .metal: return "劈拳"
        case .wood:  return "崩拳"
        case .water: return "鑽拳"
        case .fire:  return "炮拳"
        case .earth: return "橫拳"
        }
    }
    
    /// 五行相生循環關係：
    /// 金生水、水生木、木生火、火生土、土生金
    /// 當此元素施生於對象元素時，對象將恢復 1 點生命值
    var generates: FiveElement {
        switch self {
        case .metal: return .water
        case .water: return .wood
        case .wood: return .fire
        case .fire: return .earth
        case .earth: return .metal
        }
    }
    
    /// 五行相剋循環關係：
    /// 金剋木、木剋土、土剋水、水剋火、火剋金
    /// 當此元素攻擊對象元素時，對象將損失 1 點生命值
    var overcomes: FiveElement {
        switch self {
        case .metal: return .wood
        case .wood: return .earth
        case .earth: return .water
        case .water: return .fire
        case .fire: return .metal
        }
    }
    
    /// SF Symbols 視覺圖示名稱
    var iconName: String {
        switch self {
        case .metal: return "shield.fill"
        case .wood:  return "leaf.fill"
        case .water: return "drop.fill"
        case .fire:  return "flame.fill"
        case .earth: return "mountain.2.fill"
        }
    }
    
    /// 元素代表主色調（提供明亮清晰之辨識度）
    var primaryColor: Color {
        switch self {
        case .metal: return Color(red: 0.85, green: 0.72, blue: 0.35) // 澄金色
        case .wood:  return Color(red: 0.22, green: 0.68, blue: 0.38) // 翠綠色
        case .water: return Color(red: 0.18, green: 0.55, blue: 0.88) // 蔚藍色
        case .fire:  return Color(red: 0.90, green: 0.28, blue: 0.22) // 赤紅色
        case .earth: return Color(red: 0.75, green: 0.52, blue: 0.28) // 褐土色
        }
    }
    
    /// 元素次要漸層色／高光色調（用於背景氛圍與按鈕流光效果）
    var secondaryColor: Color {
        switch self {
        case .metal: return Color(red: 1.0, green: 0.9, blue: 0.55)  // 亮金色
        case .wood:  return Color(red: 0.45, green: 0.82, blue: 0.5)  // 嫩綠色
        case .water: return Color(red: 0.4, green: 0.75, blue: 0.98) // 天藍色
        case .fire:  return Color(red: 1.0, green: 0.5, blue: 0.35)  // 熾橙色
        case .earth: return Color(red: 0.88, green: 0.68, blue: 0.45) // 砂金色
        }
    }
    
    /// 五行哲學寓意與生剋口訣說明文字
    var description: String {
        switch self {
        case .metal: return "堅剛肅殺，生水剋木"
        case .wood:  return "生發條達，生火剋土"
        case .water: return "潤下靈動，生木剋火"
        case .fire:  return "炎上熾烈，生土剋金"
        case .earth: return "承載孕育，生金剋水"
        }
    }
}

// MARK: - 玩家資料模型

/// 玩家個體資料模型
/// 記錄玩家編號、名稱、是否為人工智慧（AI）、目前血量、當前出拳選擇與鎖定狀態
struct Player: Identifiable, Equatable {
    /// 玩家唯一識別編號（通常為 0, 1, 2, ...）
    let id: Int
    /// 玩家顯示名稱（例如「少俠」、「武癡」或「禪師 AI」）
    var name: String
    /// 是否由電腦 AI 控制出拳
    var isAI: Bool
    /// 目前生命值（初始通常為 2）
    var health: Int = 2
    /// 當前回合所選擇出的五行拳種；若尚未選擇或輪流換人時可為 nil
    var selection: FiveElement? = nil
    /// 是否已鎖定出拳（用於防偷看輪流機制與同屏雙人確認狀態）
    var isLocked: Bool = false
    
    /// 計算屬性：生命值是否耗盡（小於等於 0 則出局）
    var isEliminated: Bool {
        health <= 0
    }
    
    /// 計算屬性：是否存活於擂台上（生命值大於 0）
    var isAlive: Bool {
        health > 0
    }
}

// MARK: - 單回合動作結算

/// 單一玩家在某回合的具體動作與血量變更紀錄
struct PlayerRoundAction: Identifiable, Equatable {
    /// 遵循 Identifiable 協定，直接採用玩家編號
    var id: Int { playerId }
    /// 玩家識別編號
    let playerId: Int
    /// 玩家名稱
    let playerName: String
    /// 該玩家是否為 AI
    let isAI: Bool
    /// 該回合所出之五行元素
    let choice: FiveElement
    /// 回合結算前之生命值
    let hpBefore: Int
    /// 回合結算後之生命值
    let hpAfter: Int
    /// 該回合生命值增減變化（正數表示相生加血，負數表示相剋扣血，0 表示無變化）
    let hpChange: Int
    /// 結算後是否於該回合陣亡出局
    let wasEliminated: Bool
}

// MARK: - 兩兩生剋互動模型

/// 兩兩生剋交互作用的型態
enum InteractionEffect: Equatable {
    /// 相生滋養：施生者使受生者生命值 +1
    case heal
    /// 相剋重創：剋制者使受剋者生命值 -1
    case damage
}

/// 紀錄場上任意兩名玩家之間發生的五行生剋互動事件
struct PairwiseInteraction: Identifiable, Equatable {
    /// 互動事件唯一識別碼
    let id = UUID()
    /// 來源方（施生者／剋制者）玩家編號
    let sourceId: Int
    /// 來源方玩家名稱
    let sourceName: String
    /// 來源方出拳之五行元素
    let sourceElement: FiveElement
    /// 目標方（受生者／受剋者）玩家編號
    let targetId: Int
    /// 目標方玩家名稱
    let targetName: String
    /// 目標方出拳之五行元素
    let targetElement: FiveElement
    /// 交互作用效果（.heal 或 .damage）
    let effect: InteractionEffect
    /// 簡短描述字串
    let description: String
    
    /// 武學意境之生剋招式標題稱號
    var interactionTitle: String {
        switch (sourceElement, targetElement) {
        // 相生五絕招
        case (.metal, .water): return "金水相生"
        case (.water, .wood):  return "水木相生"
        case (.wood, .fire):   return "木火相生"
        case (.fire, .earth):  return "火土相生"
        case (.earth, .metal): return "土金相生"
        // 相剋五絕招
        case (.metal, .wood):  return "金剛破木"
        case (.wood, .earth):  return "盤根裂土"
        case (.earth, .water): return "崇山障水"
        case (.water, .fire):  return "狂浪熄火"
        case (.fire, .metal):  return "烈焰銷金"
        default:
            return effect == .heal ? "五行相生" : "五行相剋"
        }
    }
    
    /// 動畫全螢幕與文字戰報專用之詩意視覺解說詞
    var visualNarration: String {
        switch (sourceElement, targetElement) {
        case (.metal, .water):
            return "【金生水】靈刃化泉，金氣化生源源不絕的蔚藍清泉，滋潤水脈。"
        case (.water, .wood):
            return "【水生木】天降甘霖，清泉滋潤參天靈樹拔地而起、生生不息。"
        case (.wood, .fire):
            return "【木生火】青木引火，靈枝投薪神火轟鳴騰空，烈焰倍盛。"
        case (.fire, .earth):
            return "【火生土】神火焚化，熾烈岩漿冷卻凝聚為深厚沃土與玄武岩山。"
        case (.earth, .metal):
            return "【土生金】厚土裂地，地脈靈氣化為百鍊神鋒金刀破土而出。"
        case (.metal, .wood):
            return "【金剋木】利刃破空，大刀橫斬參天巨樹，木屑斷枝漫天飛濺！"
        case (.wood, .earth):
            return "【木剋土】青木盤根，巨根如神龍破土，崩碎厚土堅岩！"
        case (.earth, .water):
            return "【土剋水】崇山築堤，巨石如天降神壁轟然墜落，徹底截斷奔洶大水！"
        case (.water, .fire):
            return "【水剋火】狂浪傾盆，滔天巨浪澆滅烈火，升騰滾滾白霧！"
        case (.fire, .metal):
            return "【火剋金】烈火焚天，高溫烈焰銷鎔金刀，寶刃化液重創退敗！"
        default:
            return description
        }
    }
}

// MARK: - 對戰勝負結果

/// 對戰勝負結算列舉
enum BattleOutcome: String, CaseIterable, Identifiable, Equatable {
    /// 玩家獲得最後勝利
    case win = "獲勝"
    /// 玩家遭到擊敗淘汰
    case defeat = "戰敗"
    /// 平局平手（例如雙方同時陣亡或達到回合上限）
    case draw = "平手"
    
    /// 識別碼
    var id: String { rawValue }
}

// MARK: - 回合與戰局歷史紀錄

/// 完整單回合對決紀錄
/// 封裝該回合序號、所有玩家動作、兩兩生剋清單、結算摘要及是否為遊戲終局回合
struct RoundRecord: Identifiable, Equatable {
    /// 紀錄唯一識別碼
    let id: UUID
    /// 回合序號（第 1 回合、第 2 回合...）
    let roundNumber: Int
    /// 該回合所有存活玩家的出拳與血量結算明細
    let actions: [PlayerRoundAction]
    /// 該回合所有發生的兩兩相生相剋事件清單
    let interactions: [PairwiseInteraction]
    /// 該回合文字總結摘要
    let summary: String
    /// 是否為決勝（遊戲結束）回合
    var isGameOverRound: Bool
    /// 若為決勝回合，勝負結算主標題
    var battleResultTitle: String?
    /// 若為決勝回合，勝負結算詳細說明
    var battleResultDetail: String?
    /// 獲勝者名稱（平局時為 nil）
    var winnerName: String?
    
    /// 初始化單回合紀錄物件
    init(
        id: UUID = UUID(),
        roundNumber: Int,
        actions: [PlayerRoundAction],
        interactions: [PairwiseInteraction],
        summary: String,
        isGameOverRound: Bool = false,
        battleResultTitle: String? = nil,
        battleResultDetail: String? = nil,
        winnerName: String? = nil
    ) {
        self.id = id
        self.roundNumber = roundNumber
        self.actions = actions
        self.interactions = interactions
        self.summary = summary
        self.isGameOverRound = isGameOverRound
        self.battleResultTitle = battleResultTitle
        self.battleResultDetail = battleResultDetail
        self.winnerName = winnerName
    }
}

/// 完整整場對戰歷史紀錄（用於戰報回顧與戰績統計）
struct BattleRecord: Identifiable, Equatable {
    /// 戰報唯一識別碼
    let id: UUID
    /// 對戰結束時間
    let date: Date
    /// 遊戲模式（人機對戰、同機輪流、雙人同屏）
    let gameMode: GameMode
    /// 參戰玩家人數（2~4 人）
    let playerCount: Int
    /// 開局初始生命值設定（例如 2 點）
    let initialHealth: Int
    /// 達成獲勝之最高生命值設定
    let winningHealth: Int
    /// 總計進行回合數
    let totalRounds: Int
    /// 最終獲勝者名稱（平局時為 nil）
    let winnerName: String?
    /// 結算主標題（例如「榮登武林之巔」）
    let resultTitle: String
    /// 結算詳細評語與戰情總結
    let resultDetail: String
    /// 對戰結果屬性（獲勝、戰敗、平手）
    let outcome: BattleOutcome
    /// 最終結算時各玩家的狀態列表
    let finalPlayers: [Player]
    /// 整場對決中所有回合的歷程紀錄列表
    let rounds: [RoundRecord]
    
    /// 初始化整場戰報物件
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        gameMode: GameMode,
        playerCount: Int,
        initialHealth: Int,
        winningHealth: Int,
        totalRounds: Int,
        winnerName: String?,
        resultTitle: String,
        resultDetail: String,
        outcome: BattleOutcome,
        finalPlayers: [Player],
        rounds: [RoundRecord]
    ) {
        self.id = id
        self.date = date
        self.gameMode = gameMode
        self.playerCount = playerCount
        self.initialHealth = initialHealth
        self.winningHealth = winningHealth
        self.totalRounds = totalRounds
        self.winnerName = winnerName
        self.resultTitle = resultTitle
        self.resultDetail = resultDetail
        self.outcome = outcome
        self.finalPlayers = finalPlayers
        self.rounds = rounds
    }
}

// MARK: - 遊戲模式

/// 遊戲對戰模式列舉
enum GameMode: String, CaseIterable, Identifiable {
    /// 人機對戰模式：單人與 1~3 位 AI 電腦禪師對弈
    case vsAI = "人機對戰"
    /// 同機輪流模式：2~4 位玩家在同一裝置上傳遞輪流暗選出拳
    case pvpPass = "同機輪流"
    /// 雙人同屏模式：兩位玩家各佔螢幕一端同時出拳對決
    case pvpTogether = "雙人同屏"
    
    /// 唯一識別碼
    var id: String { rawValue }
    
    /// 模式副標題說明
    var subtitle: String {
        switch self {
        case .vsAI: return "可自選 1~3 名 AI 禪師混戰"
        case .pvpPass: return "支援 2~4 人輪流暗選對決"
        case .pvpTogether: return "面對面同屏，考驗心性反應"
        }
    }
}
