//
//  Models.swift
//  五行拳
//

import SwiftUI

/// 五行元素定義
enum FiveElement: String, CaseIterable, Identifiable {
    case metal = "金"
    case wood = "木"
    case water = "水"
    case fire = "火"
    case earth = "土"
    
    var id: String { rawValue }
    
    /// 五行拳招式名稱（形意五行拳）
    var attackName: String {
        switch self {
        case .metal: return "劈拳"
        case .wood:  return "崩拳"
        case .water: return "鑽拳"
        case .fire:  return "炮拳"
        case .earth: return "橫拳"
        }
    }
    
    /// 相生關係：金生水，水生木，木生火，火生土，土生金
    var generates: FiveElement {
        switch self {
        case .metal: return .water
        case .water: return .wood
        case .wood: return .fire
        case .fire: return .earth
        case .earth: return .metal
        }
    }
    
    /// 相剋關係：金剋木，木剋土，土剋水，水剋火，火剋金
    var overcomes: FiveElement {
        switch self {
        case .metal: return .wood
        case .wood: return .earth
        case .earth: return .water
        case .water: return .fire
        case .fire: return .metal
        }
    }
    
    /// 圖示
    var iconName: String {
        switch self {
        case .metal: return "shield.fill"
        case .wood:  return "leaf.fill"
        case .water: return "drop.fill"
        case .fire:  return "flame.fill"
        case .earth: return "mountain.2.fill"
        }
    }
    
    /// 代表色彩
    var primaryColor: Color {
        switch self {
        case .metal: return Color(red: 0.85, green: 0.72, blue: 0.35)
        case .wood:  return Color(red: 0.22, green: 0.68, blue: 0.38)
        case .water: return Color(red: 0.18, green: 0.55, blue: 0.88)
        case .fire:  return Color(red: 0.90, green: 0.28, blue: 0.22)
        case .earth: return Color(red: 0.75, green: 0.52, blue: 0.28)
        }
    }
    
    /// 次要/漸層色彩
    var secondaryColor: Color {
        switch self {
        case .metal: return Color(red: 1.0, green: 0.9, blue: 0.55)
        case .wood:  return Color(red: 0.45, green: 0.82, blue: 0.5)
        case .water: return Color(red: 0.4, green: 0.75, blue: 0.98)
        case .fire:  return Color(red: 1.0, green: 0.5, blue: 0.35)
        case .earth: return Color(red: 0.88, green: 0.68, blue: 0.45)
        }
    }
    
    /// 五行寓意
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

/// 玩家資料模型
struct Player: Identifiable, Equatable {
    let id: Int
    var name: String
    var isAI: Bool
    var health: Int = 2
    var selection: FiveElement? = nil
    var isLocked: Bool = false
    
    var isEliminated: Bool {
        health <= 0
    }
    
    var isAlive: Bool {
        health > 0
    }
}

/// 單回合玩家出拳與結算狀態
struct PlayerRoundAction: Identifiable, Equatable {
    var id: Int { playerId }
    let playerId: Int
    let playerName: String
    let isAI: Bool
    let choice: FiveElement
    let hpBefore: Int
    let hpAfter: Int
    let hpChange: Int
    let wasEliminated: Bool
}

/// 兩兩生剋交互作用型態
enum InteractionEffect: Equatable {
    case heal   // 生：受生者生命 +1
    case damage // 剋：受剋者生命 -1
}

/// 兩兩五行生剋紀錄
struct PairwiseInteraction: Identifiable, Equatable {
    let id = UUID()
    let sourceId: Int
    let sourceName: String
    let sourceElement: FiveElement
    let targetId: Int
    let targetName: String
    let targetElement: FiveElement
    let effect: InteractionEffect
    let description: String
    
    /// 生剋招式稱號
    var interactionTitle: String {
        switch (sourceElement, targetElement) {
        // 相生
        case (.metal, .water): return "金水相生"
        case (.water, .wood):  return "水木相生"
        case (.wood, .fire):   return "木火相生"
        case (.fire, .earth):  return "火土相生"
        case (.earth, .metal): return "土金相生"
        // 相剋
        case (.metal, .wood):  return "金剛破木"
        case (.wood, .earth):  return "盤根裂土"
        case (.earth, .water): return "崇山障水"
        case (.water, .fire):  return "狂浪熄火"
        case (.fire, .metal):  return "烈焰銷金"
        default:
            return effect == .heal ? "五行相生" : "五行相剋"
        }
    }
    
    /// 動畫視覺詩意解說
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
            return "【火剋金】烈火焚天，高溫烈焰銷鑠金刀，寶刃化液重創退敗！"
        default:
            return description
        }
    }
}

/// 對戰勝負結果型態
enum BattleOutcome: String, CaseIterable, Identifiable, Equatable {
    case win = "獲勝"
    case defeat = "戰敗"
    case draw = "平手"
    
    var id: String { rawValue }
}

/// 完整單回合對決記錄
struct RoundRecord: Identifiable, Equatable {
    let id: UUID
    let roundNumber: Int
    let actions: [PlayerRoundAction]
    let interactions: [PairwiseInteraction]
    let summary: String
    var isGameOverRound: Bool
    var battleResultTitle: String?
    var battleResultDetail: String?
    var winnerName: String?
    
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

/// 完整對戰記錄（包含整場對決結果、設定與各回合明細）
struct BattleRecord: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let gameMode: GameMode
    let playerCount: Int
    let initialHealth: Int
    let winningHealth: Int
    let totalRounds: Int
    let winnerName: String?
    let resultTitle: String
    let resultDetail: String
    let outcome: BattleOutcome
    let finalPlayers: [Player]
    let rounds: [RoundRecord]
    
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

/// 遊戲模式
enum GameMode: String, CaseIterable, Identifiable {
    case vsAI = "人機對戰"
    case pvpPass = "同機輪流"
    case pvpTogether = "雙人同屏"
    
    var id: String { rawValue }
    
    var subtitle: String {
        switch self {
        case .vsAI: return "可自選 1~3 名 AI 禪師混戰"
        case .pvpPass: return "支援 2~4 人輪流暗選對決"
        case .pvpTogether: return "面對面同屏，考驗心性反應"
        }
    }
}
