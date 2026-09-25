//
//  GameViewModel.swift
//  五行拳
//
//  五行拳遊戲核心視圖模型（View Model）模組
//  使用 Swift 現代 Observation 框架（@Observable）
//  負責驅動對戰狀態機、三種遊玩模式、五行生剋即時判定演算法、終局條件檢驗與歷史戰報管理
//

import SwiftUI
import Observation

/// 輪流暗選出拳模式之流程階段狀態列舉
enum PassTurnStep: Equatable {
    /// 該輪由指定索引之玩家暗自選拳
    case choosing(playerIndex: Int)
    /// 該玩家已選拳，畫面遮蔽並提示將裝置交給下一位玩家
    case waitingNextPlayer(nextPlayerIndex: Int)
    /// 所有存活玩家皆已出拳完畢，進入揭曉結算階段
    case revealed
}

/// 五行拳遊戲主要業務邏輯控制中心（Game View Model）
@Observable
class FiveElementsGameViewModel {
    
    /// 防止在連續調整設定數值時觸發重複遞迴 reset 的旗標
    private var isUpdatingSettings = false
    
    // MARK: - 遊戲設定屬性
    
    /// 目前遊玩模式（人機對戰、同機輪流、雙人同屏）
    var gameMode: GameMode = .vsAI {
        didSet {
            guard oldValue != gameMode else { return }
            isUpdatingSettings = true
            // 每當切換不同遊玩模式時，重置初始生命值與獲勝生命值為標準預設值（初始 2 點、獲勝 5 點）
            winningHealth = 5
            initialHealth = 2
            // 若切換為雙人同屏模式，固定強制為 2 人對決
            if gameMode == .pvpTogether {
                playerCount = 2
            }
            isUpdatingSettings = false
            resetGame()
        }
    }
    
    /// 參戰總玩家人數（支援 2 ~ 4 人）
    var playerCount: Int = 4 {
        didSet {
            // 雙人同屏固定為 2 人；其餘模式限制在 2 至 4 人範圍內
            let clamped = (gameMode == .pvpTogether) ? 2 : max(2, min(4, playerCount))
            if playerCount != clamped {
                playerCount = clamped
                return
            }
            if !isUpdatingSettings {
                resetGame()
            }
        }
    }
    
    /// 達成獲勝所需的最高生命值（預設 5 點，可設定範圍 4 ~ 10 點）
    var winningHealth: Int = 5 {
        didSet {
            let clamped = max(4, min(10, winningHealth))
            if winningHealth != clamped {
                winningHealth = clamped
                return
            }
            // 規則約束：開局初始生命值最高僅能為獲勝目標生命值的一半（無條件捨去小數）
            let maxInitial = winningHealth / 2
            if initialHealth > maxInitial {
                initialHealth = maxInitial
            } else if !isUpdatingSettings {
                resetGame()
            }
        }
    }
    
    /// 開局初始生命值（預設 2 點，最低 2 點，最高為 winningHealth / 2）
    var initialHealth: Int = 2 {
        didSet {
            let maxInitial = max(2, winningHealth / 2)
            let clamped = max(2, min(maxInitial, initialHealth))
            if initialHealth != clamped {
                initialHealth = clamped
                return
            }
            if !isUpdatingSettings {
                resetGame()
            }
        }
    }
    
    /// 計算屬性：當前獲勝生命值所允許之初始生命值最大上限
    var maxInitialHealth: Int {
        winningHealth / 2
    }
    
    // MARK: - 玩家與回合狀態
    
    /// 場上所有玩家的實體陣列
    var players: [Player] = []
    
    /// 輪流換手暗選模式下的當前步驟
    var passTurnStep: PassTurnStep = .choosing(playerIndex: 0)
    
    /// 是否已揭曉全體玩家出拳結果
    var isRevealed: Bool = false
    
    /// 是否彈出全螢幕出拳與相生相剋動態劇院視圖
    var showClashTheater: Bool = false
    
    /// 當前在全螢幕劇院中正在展示的生剋對決組別索引
    var activeClashIndex: Int = 0
    
    /// 目前進行之回合序號（自第 1 回合起算）
    var roundNumber: Int = 1
    
    /// 當前整場對局的各回合歷程紀錄清單（由新至舊排序）
    var history: [RoundRecord] = []
    
    /// 歷史對局紀錄清單（整場勝負戰報）
    var battleHistory: [BattleRecord] = []
    
    /// 最近一次剛結算完成的回合紀錄
    var lastRecord: RoundRecord? = nil
    
    // MARK: - 勝負終局狀態
    
    /// 整場遊戲是否已分出勝負（終局）
    var isGameOver: Bool = false
    
    /// 最終獲勝者名稱（平局時為 nil）
    var winnerName: String? = nil
    
    /// 終局告示主標題（例如「🎉 少俠 獲勝！」）
    var gameOverTitle: String = ""
    
    /// 終局告示詳細敘述文字
    var gameOverDetail: String = ""
    
    /// 畫面上方的動態提示與解說橫幅文字
    var announcementText: String = ""
    
    // MARK: - 初始化
    
    /// 建立視圖模型並初始化遊戲開局
    init() {
        resetGame()
    }
    
    // MARK: - 重置遊戲邏輯
    
    /// 重新開始新賽局：將生命值設定還原為官方標準預設值（初始 2 點、獲勝 5 點），並重啟棋局
    func restartGame() {
        resetGame(restoreHealthDefaults: true)
    }
    
    /// 重置當前遊戲擂台狀態
    /// - Parameter restoreHealthDefaults: 是否同時將初始血量與獲勝血量還原為預設設定
    func resetGame(restoreHealthDefaults: Bool = false) {
        if restoreHealthDefaults {
            isUpdatingSettings = true
            winningHealth = 5
            initialHealth = 2
            isUpdatingSettings = false
        }
        
        // 重置狀態旗標與計數器
        isRevealed = false
        showClashTheater = false
        activeClashIndex = 0
        roundNumber = 1
        history.removeAll()
        lastRecord = nil
        isGameOver = false
        winnerName = nil
        gameOverTitle = ""
        gameOverDetail = ""
        
        // 依據目前模式與人數重新產生玩家陣容
        setupPlayers()
        
        // 依模式初始化第一回合之引導文案
        switch gameMode {
        case .vsAI:
            passTurnStep = .choosing(playerIndex: 0)
            let aiCount = playerCount - 1
            announcementText = "第 1 回合：請出拳挑戰 \(aiCount) 位 AI 禪師！"
        case .pvpPass:
            passTurnStep = .choosing(playerIndex: 0)
            announcementText = "第 1 回合：請【\(players.first?.name ?? "玩家一")】暗選出拳"
        case .pvpTogether:
            passTurnStep = .choosing(playerIndex: 0)
            announcementText = "第 1 回合：雙方各自暗選後確認"
        }
    }
    
    /// 根據目前設定的 gameMode 與 playerCount 生成對應的玩家名單
    private func setupPlayers() {
        var newPlayers: [Player] = []
        
        switch gameMode {
        case .vsAI:
            // 玩家固定為 1 號
            newPlayers.append(Player(id: 1, name: "玩家", isAI: false, health: initialHealth))
            // 根據設定人數生成 1 ~ 3 位 AI 禪師對手
            let aiCount = playerCount - 1
            for i in 1...aiCount {
                let name = aiCount == 1 ? "AI 禪師" : "AI 禪師 \(i)"
                newPlayers.append(Player(id: i + 1, name: name, isAI: true, health: initialHealth))
            }
            
        case .pvpPass:
            let chineseNumbers = ["一", "二", "三", "四"]
            for i in 0..<playerCount {
                let name = "玩家\(chineseNumbers[i])"
                newPlayers.append(Player(id: i + 1, name: name, isAI: false, health: initialHealth))
            }
            
        case .pvpTogether:
            newPlayers.append(Player(id: 1, name: "玩家一", isAI: false, health: initialHealth))
            newPlayers.append(Player(id: 2, name: "玩家二", isAI: false, health: initialHealth))
        }
        
        players = newPlayers
    }
    
    // MARK: - 玩家出拳操作處理
    
    /// 人機對戰模式：人類玩家選定出拳後，自動為所有存活之 AI 電腦隨機選拳，並立即執行生剋結算
    /// - Parameter element: 人類玩家所選之五行元素
    func playerChooseVsAI(_ element: FiveElement) {
        guard !isGameOver, !isRevealed else { return }
        guard let pIndex = players.firstIndex(where: { !$0.isAI && $0.isAlive }) else { return }
        
        // 紀錄玩家出拳
        players[pIndex].selection = element
        
        // 為所有存活之 AI 隨機抽取五行元素
        for i in 0..<players.count {
            if players[i].isAI && players[i].isAlive {
                players[i].selection = FiveElement.allCases.randomElement()
            }
        }
        
        // 進行生剋結算
        resolveRound()
    }
    
    /// 同機輪流暗選模式：指定索引之玩家選擇出拳
    /// - Parameters:
    ///   - playerIndex: 當前選拳玩家在陣列中之索引
    ///   - element: 該玩家所選之五行元素
    func passPlayerChoose(playerIndex: Int, element: FiveElement) {
        guard !isGameOver, !isRevealed else { return }
        guard players.indices.contains(playerIndex) else { return }
        
        players[playerIndex].selection = element
        
        // 尋找下一位仍存活且尚未選拳的玩家
        if let nextIndex = nextUnselectedAlivePlayerIndex(after: playerIndex) {
            withAnimation(.easeInOut(duration: 0.3)) {
                passTurnStep = .waitingNextPlayer(nextPlayerIndex: nextIndex)
                announcementText = "【\(players[playerIndex].name)】已選定！請將設備交給【\(players[nextIndex].name)】"
            }
        } else {
            // 所有在場存活玩家皆已出拳完畢，立即揭曉並結算
            resolveRound()
        }
    }
    
    /// 輪流模式：下一位玩家已就定位並點擊確認，開始該玩家的選拳畫面
    /// - Parameter playerIndex: 換手後的玩家索引
    func startNextPassPlayerTurn(playerIndex: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            passTurnStep = .choosing(playerIndex: playerIndex)
            announcementText = "請【\(players[playerIndex].name)】暗自選出五行拳"
        }
    }
    
    /// 雙人同屏模式：上方玩家（P1）出拳並鎖定
    /// - Parameter element: P1 選定之五行拳種
    func pvpTogetherP1Choose(_ element: FiveElement) {
        guard !isGameOver, !isRevealed, players.count >= 2 else { return }
        players[0].selection = element
        players[0].isLocked = true
        checkTogetherReveal()
    }
    
    /// 雙人同屏模式：下方玩家（P2）出拳並鎖定
    /// - Parameter element: P2 選定之五行拳種
    func pvpTogetherP2Choose(_ element: FiveElement) {
        guard !isGameOver, !isRevealed, players.count >= 2 else { return }
        players[1].selection = element
        players[1].isLocked = true
        checkTogetherReveal()
    }
    
    /// 檢查同屏雙方是否皆已鎖定出拳，若皆鎖定則自動揭曉結算
    private func checkTogetherReveal() {
        if players.count >= 2 && players[0].isLocked && players[1].isLocked {
            resolveRound()
        }
    }
    
    /// 輔助方法：由目前索引往後依序輪詢下一位尚未出拳之存活玩家索引
    private func nextUnselectedAlivePlayerIndex(after currentIndex: Int) -> Int? {
        let count = players.count
        for step in 1..<count {
            let idx = (currentIndex + step) % count
            if players[idx].isAlive && players[idx].selection == nil {
                return idx
            }
        }
        return nil
    }
    
    // MARK: - 回合多方五行生剋判定演算法
    
    /// 核心結算函式：
    /// 進行場上所有存活玩家兩兩配對（Pairwise）檢驗相生與相剋關係：
    /// - 相生：被生者生命值 +1（上限為 winningHealth）
    /// - 相剋：被剋者生命值 -1（扣至 0 則出局）
    /// - 同元素：勢均力敵，不產生任何生命增減
    private func resolveRound() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isRevealed = true
            passTurnStep = .revealed
        }
        
        let activePlayers = players.filter { $0.isAlive && $0.selection != nil }
        guard !activePlayers.isEmpty else { return }
        
        // 初始化各玩家該回合的血量變動值累加字典
        var deltaHp: [Int: Int] = [:]
        for p in activePlayers {
            deltaHp[p.id] = 0
        }
        
        var interactions: [PairwiseInteraction] = []
        
        // 兩兩對決全組合判定演算法（O(N^2)）
        for i in 0..<activePlayers.count {
            for j in (i + 1)..<activePlayers.count {
                let pA = activePlayers[i]
                let pB = activePlayers[j]
                guard let elemA = pA.selection, let elemB = pB.selection else { continue }
                
                if elemA == elemB {
                    // 同屬性，內力相抵，勢均力敵
                    continue
                } else if elemA.generates == elemB {
                    // A 生 B：B 生命 +1
                    deltaHp[pB.id, default: 0] += 1
                    interactions.append(PairwiseInteraction(
                        sourceId: pA.id,
                        sourceName: pA.name,
                        sourceElement: elemA,
                        targetId: pB.id,
                        targetName: pB.name,
                        targetElement: elemB,
                        effect: .heal,
                        description: "【\(elemA.rawValue)】生【\(elemB.rawValue)】：\(pA.name) 滋養了 \(pB.name)（\(pB.name) +1）"
                    ))
                } else if elemB.generates == elemA {
                    // B 生 A：A 生命 +1
                    deltaHp[pA.id, default: 0] += 1
                    interactions.append(PairwiseInteraction(
                        sourceId: pB.id,
                        sourceName: pB.name,
                        sourceElement: elemB,
                        targetId: pA.id,
                        targetName: pA.name,
                        targetElement: elemA,
                        effect: .heal,
                        description: "【\(elemB.rawValue)】生【\(elemA.rawValue)】：\(pB.name) 滋養了 \(pA.name)（\(pA.name) +1）"
                    ))
                } else if elemA.overcomes == elemB {
                    // A 剋 B：B 生命 -1
                    deltaHp[pB.id, default: 0] -= 1
                    interactions.append(PairwiseInteraction(
                        sourceId: pA.id,
                        sourceName: pA.name,
                        sourceElement: elemA,
                        targetId: pB.id,
                        targetName: pB.name,
                        targetElement: elemB,
                        effect: .damage,
                        description: "【\(elemA.rawValue)】剋【\(elemB.rawValue)】：\(pA.name) 重創了 \(pB.name)（\(pB.name) -1）"
                    ))
                } else if elemB.overcomes == elemA {
                    // B 剋 A：A 生命 -1
                    deltaHp[pA.id, default: 0] -= 1
                    interactions.append(PairwiseInteraction(
                        sourceId: pB.id,
                        sourceName: pB.name,
                        sourceElement: elemB,
                        targetId: pA.id,
                        targetName: pA.name,
                        targetElement: elemA,
                        effect: .damage,
                        description: "【\(elemB.rawValue)】剋【\(elemA.rawValue)】：\(pB.name) 重創了 \(pA.name)（\(pA.name) -1）"
                    ))
                }
            }
        }
        
        // 正式更新各玩家之生命值，並記錄各玩家的動作結算物件
        var actionRecords: [PlayerRoundAction] = []
        for idx in 0..<players.count {
            if players[idx].isAlive, let choice = players[idx].selection {
                let change = deltaHp[players[idx].id, default: 0]
                let hpBefore = players[idx].health
                let hpAfter = max(0, min(winningHealth, hpBefore + change))
                players[idx].health = hpAfter
                
                actionRecords.append(PlayerRoundAction(
                    playerId: players[idx].id,
                    playerName: players[idx].name,
                    isAI: players[idx].isAI,
                    choice: choice,
                    hpBefore: hpBefore,
                    hpAfter: hpAfter,
                    hpChange: change,
                    wasEliminated: hpAfter <= 0
                ))
            }
        }
        
        // 彙整戰情文字摘要
        let summary: String
        if interactions.isEmpty {
            summary = "全員氣脈相同，勢均力敵，無生剋發生！"
        } else {
            summary = interactions.map { $0.description }.joined(separator: "；")
        }
        
        // 檢驗本回合是否分出勝負（是否達成終局條件）
        checkGameOver()
        
        if isGameOver {
            announcementText = "\(summary) 【\(gameOverTitle)】"
        } else {
            announcementText = summary
        }
        
        // 封裝單回合紀錄並插入歷史清單首位
        let record = RoundRecord(
            roundNumber: roundNumber,
            actions: actionRecords,
            interactions: interactions,
            summary: summary,
            isGameOverRound: isGameOver,
            battleResultTitle: isGameOver ? gameOverTitle : nil,
            battleResultDetail: isGameOver ? gameOverDetail : nil,
            winnerName: isGameOver ? winnerName : nil
        )
        lastRecord = record
        history.insert(record, at: 0)
        
        // 若勝負已分，正式寫入整場對戰歷史紀錄庫
        if isGameOver {
            recordBattleResult()
        }
        
        // 自動啟動全螢幕出拳生剋動畫劇院
        activeClashIndex = 0
        showClashTheater = true
    }
    
    // MARK: - 勝負終局條件檢驗
    
    /// 檢驗是否有玩家達到獲勝條件或出局條件：
    /// 1. 達到獲勝生命值者（五行大成）獲勝
    /// 2. 僅剩一人存活時，該生還者獲勝
    /// 3. 人機對戰中若人類玩家陣亡，則直接判定戰敗
    /// 4. 若全員同時陣亡，則判定平手（同歸於盡）
    private func checkGameOver() {
        // 條件 1：檢查是否有玩家達到獲勝生命值（五行大成）
        let maxHpPlayers = players.filter { $0.health >= winningHealth }
        if !maxHpPlayers.isEmpty {
            isGameOver = true
            let winner = maxHpPlayers.max(by: { $0.health < $1.health })!
            winnerName = winner.name
            gameOverTitle = "🎉 \(winner.name) 獲勝！"
            gameOverDetail = "\(winner.name) 生命值率先積滿 \(winningHealth) 點，五行大成，登峰造極！"
            return
        }
        
        // 條件 2：檢查存活人數
        let alivePlayers = players.filter { $0.isAlive }
        
        // 條件 3：若在人機對戰中，人類玩家出局
        if gameMode == .vsAI {
            if let human = players.first(where: { !$0.isAI }), human.isEliminated {
                isGameOver = true
                if alivePlayers.count == 1 {
                    winnerName = alivePlayers[0].name
                    gameOverTitle = "💀 玩家已出局！"
                    gameOverDetail = "您的生命值已歸零，挑戰失敗！\(alivePlayers[0].name) 成為最終勝者。"
                } else {
                    winnerName = nil
                    gameOverTitle = "💀 玩家已出局！"
                    gameOverDetail = "您的生命值已歸零，氣息斷絕，挑戰失敗！"
                }
                return
            }
        }
        
        // 條件 4：若僅剩 1 人生還
        if alivePlayers.count == 1 {
            let survivor = alivePlayers[0]
            isGameOver = true
            winnerName = survivor.name
            gameOverTitle = "🏆 \(survivor.name) 獲勝！"
            gameOverDetail = "其餘對手皆已出局，\(survivor.name) 成為唯一生還的武林至尊！"
            return
        }
        
        // 條件 5：全員同時陣亡
        if alivePlayers.isEmpty {
            isGameOver = true
            winnerName = nil
            gameOverTitle = "⚖️ 同歸於盡！"
            gameOverDetail = "所有參戰者生命值同時歸零，平手作收！"
            return
        }
    }
    
    // MARK: - 對戰歷史戰報結算
    
    /// 當整場對局結束時，將完整戰況統整為 BattleRecord 寫入歷史戰報庫
    private func recordBattleResult() {
        let outcome: BattleOutcome
        if gameMode == .vsAI {
            if let human = players.first(where: { !$0.isAI }), human.isEliminated {
                outcome = .defeat
            } else if winnerName == "玩家" {
                outcome = .win
            } else if winnerName != nil {
                outcome = .defeat
            } else {
                outcome = .draw
            }
        } else {
            outcome = (winnerName != nil) ? .win : .draw
        }
        
        let battle = BattleRecord(
            date: Date(),
            gameMode: gameMode,
            playerCount: playerCount,
            initialHealth: initialHealth,
            winningHealth: winningHealth,
            totalRounds: roundNumber,
            winnerName: winnerName,
            resultTitle: gameOverTitle,
            resultDetail: gameOverDetail,
            outcome: outcome,
            finalPlayers: players,
            rounds: history
        )
        battleHistory.insert(battle, at: 0)
    }
    
    /// 清除所有歷史戰報紀錄
    func clearBattleHistory() {
        battleHistory.removeAll()
    }
    
    // MARK: - 回合切換推進
    
    /// 推進進入下一回合：重置本回合出拳狀態與鎖定狀態，並切換輪流提示
    func nextRound() {
        guard !isGameOver else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            roundNumber += 1
            isRevealed = false
            showClashTheater = false
            activeClashIndex = 0
            lastRecord = nil
            
            // 重置每位玩家之出拳與鎖定標記
            for i in 0..<players.count {
                players[i].selection = nil
                players[i].isLocked = false
            }
            
            // 找出第一位未淘汰之存活玩家
            let firstAliveIndex = players.firstIndex(where: { $0.isAlive }) ?? 0
            passTurnStep = .choosing(playerIndex: firstAliveIndex)
            
            // 依模式更新導引文字
            switch gameMode {
            case .vsAI:
                let aliveAiCount = players.filter { $0.isAI && $0.isAlive }.count
                announcementText = "第 \(roundNumber) 回合：請出拳挑戰剩餘 \(aliveAiCount) 位 AI！"
            case .pvpPass:
                announcementText = "第 \(roundNumber) 回合：請【\(players[firstAliveIndex].name)】暗自選拳"
            case .pvpTogether:
                announcementText = "第 \(roundNumber) 回合：雙方各自暗選後確認"
            }
        }
    }
}
