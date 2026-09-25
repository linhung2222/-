//
//  GameViewModel.swift
//  五行拳
//

import SwiftUI
import Observation

/// 輪流暗選階段
enum PassTurnStep: Equatable {
    case choosing(playerIndex: Int)
    case waitingNextPlayer(nextPlayerIndex: Int)
    case revealed
}

@Observable
class FiveElementsGameViewModel {
    private var isUpdatingSettings = false
    
    // 遊戲模式
    var gameMode: GameMode = .vsAI {
        didSet {
            guard oldValue != gameMode else { return }
            isUpdatingSettings = true
            // 每次切換不同模式都重置初始生命值及獲勝生命值（初始為2獲勝為5）
            winningHealth = 5
            initialHealth = 2
            if gameMode == .pvpTogether {
                playerCount = 2
            }
            isUpdatingSettings = false
            resetGame()
        }
    }
    
    // 總玩家人數 (支援 2 ~ 4 人)
    var playerCount: Int = 4 {
        didSet {
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
    
    // 獲勝生命值（預設 5，範圍 4 ~ 10）
    var winningHealth: Int = 5 {
        didSet {
            let clamped = max(4, min(10, winningHealth))
            if winningHealth != clamped {
                winningHealth = clamped
                return
            }
            // 初始生命值最高只能為獲勝生命值的一半（捨去小數點）
            let maxInitial = winningHealth / 2
            if initialHealth > maxInitial {
                initialHealth = maxInitial
            } else if !isUpdatingSettings {
                resetGame()
            }
        }
    }
    
    // 初始生命值（預設 2，最低 2，最高為 winningHealth / 2）
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
    
    /// 初始生命值當前允許的最大上限（獲勝生命值的一半且捨去小數點）
    var maxInitialHealth: Int {
        winningHealth / 2
    }
    
    // 玩家清單
    var players: [Player] = []
    
    // 輪流出拳流程階段
    var passTurnStep: PassTurnStep = .choosing(playerIndex: 0)
    
    // 是否已揭曉結果
    var isRevealed: Bool = false
    
    // 全螢幕出拳與生剋動畫劇院
    var showClashTheater: Bool = false
    var activeClashIndex: Int = 0
    
    // 回合數與戰局歷程
    var roundNumber: Int = 1
    var history: [RoundRecord] = []
    var battleHistory: [BattleRecord] = []
    var lastRecord: RoundRecord? = nil
    
    // 勝負狀態
    var isGameOver: Bool = false
    var winnerName: String? = nil
    var gameOverTitle: String = ""
    var gameOverDetail: String = ""
    
    // 提示與回饋文字
    var announcementText: String = ""
    
    init() {
        resetGame()
    }
    
    // MARK: - 重置遊戲
    
    /// 重新開始遊戲：將生命值回復為預設值（初始 2 點、獲勝 5 點），並重置遊戲狀態
    func restartGame() {
        resetGame(restoreHealthDefaults: true)
    }
    
    func resetGame(restoreHealthDefaults: Bool = false) {
        if restoreHealthDefaults {
            isUpdatingSettings = true
            winningHealth = 5
            initialHealth = 2
            isUpdatingSettings = false
        }
        
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
        
        setupPlayers()
        
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
    
    private func setupPlayers() {
        var newPlayers: [Player] = []
        
        switch gameMode {
        case .vsAI:
            // 玩家為 1 號
            newPlayers.append(Player(id: 1, name: "玩家", isAI: false, health: initialHealth))
            // 根據人數生成 1 ~ 3 位 AI
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
    
    // MARK: - 玩家出拳操作
    
    /// 人機對戰：玩家選拳後，所有未出局的 AI 同步隨機選拳並立即結算
    func playerChooseVsAI(_ element: FiveElement) {
        guard !isGameOver, !isRevealed else { return }
        guard let pIndex = players.firstIndex(where: { !$0.isAI && $0.isAlive }) else { return }
        
        players[pIndex].selection = element
        
        // 讓其餘未淘汰的 AI 隨機出拳
        for i in 0..<players.count {
            if players[i].isAI && players[i].isAlive {
                players[i].selection = FiveElement.allCases.randomElement()
            }
        }
        
        resolveRound()
    }
    
    /// 輪流模式：指定索引玩家選拳
    func passPlayerChoose(playerIndex: Int, element: FiveElement) {
        guard !isGameOver, !isRevealed else { return }
        guard players.indices.contains(playerIndex) else { return }
        
        players[playerIndex].selection = element
        
        // 尋找下一位未出局且尚未出拳的玩家
        if let nextIndex = nextUnselectedAlivePlayerIndex(after: playerIndex) {
            withAnimation(.easeInOut(duration: 0.3)) {
                passTurnStep = .waitingNextPlayer(nextPlayerIndex: nextIndex)
                announcementText = "【\(players[playerIndex].name)】已選定！請將設備交給【\(players[nextIndex].name)】"
            }
        } else {
            // 所有在場存活用戶皆已出拳，進行揭曉與結算
            resolveRound()
        }
    }
    
    /// 輪流模式：下一位玩家接過設備，開始選拳
    func startNextPassPlayerTurn(playerIndex: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            passTurnStep = .choosing(playerIndex: playerIndex)
            announcementText = "請【\(players[playerIndex].name)】暗自選出五行拳"
        }
    }
    
    /// 雙人同屏：P1 選拳
    func pvpTogetherP1Choose(_ element: FiveElement) {
        guard !isGameOver, !isRevealed, players.count >= 2 else { return }
        players[0].selection = element
        players[0].isLocked = true
        checkTogetherReveal()
    }
    
    /// 雙人同屏：P2 選拳
    func pvpTogetherP2Choose(_ element: FiveElement) {
        guard !isGameOver, !isRevealed, players.count >= 2 else { return }
        players[1].selection = element
        players[1].isLocked = true
        checkTogetherReveal()
    }
    
    private func checkTogetherReveal() {
        if players.count >= 2 && players[0].isLocked && players[1].isLocked {
            resolveRound()
        }
    }
    
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
    
    // MARK: - 回合多方生剋判定
    
    private func resolveRound() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isRevealed = true
            passTurnStep = .revealed
        }
        
        let activePlayers = players.filter { $0.isAlive && $0.selection != nil }
        guard !activePlayers.isEmpty else { return }
        
        var deltaHp: [Int: Int] = [:]
        for p in activePlayers {
            deltaHp[p.id] = 0
        }
        
        var interactions: [PairwiseInteraction] = []
        
        // 兩兩對決判定 (Pairwise interactions)
        for i in 0..<activePlayers.count {
            for j in (i + 1)..<activePlayers.count {
                let pA = activePlayers[i]
                let pB = activePlayers[j]
                guard let elemA = pA.selection, let elemB = pB.selection else { continue }
                
                if elemA == elemB {
                    // 同屬性，勢均力敵
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
        
        // 套用結算後的血量變化
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
        
        // 產生戰況摘要
        let summary: String
        if interactions.isEmpty {
            summary = "全員氣脈相同，勢均力敵，無生剋發生！"
        } else {
            summary = interactions.map { $0.description }.joined(separator: "；")
        }
        
        // 先行判斷勝負條件以利記錄於本回合與對戰記錄中
        checkGameOver()
        
        if isGameOver {
            announcementText = "\(summary) 【\(gameOverTitle)】"
        } else {
            announcementText = summary
        }
        
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
        
        // 若勝負已分，正式寫入整場對戰歷史記錄
        if isGameOver {
            recordBattleResult()
        }
        
        // 自動啟動全螢幕出拳生剋動畫劇院
        activeClashIndex = 0
        showClashTheater = true
    }
    
    private func checkGameOver() {
        // 檢查是否有玩家達到獲勝生命值（五行大成）
        let maxHpPlayers = players.filter { $0.health >= winningHealth }
        if !maxHpPlayers.isEmpty {
            isGameOver = true
            let winner = maxHpPlayers.max(by: { $0.health < $1.health })!
            winnerName = winner.name
            gameOverTitle = "🎉 \(winner.name) 獲勝！"
            gameOverDetail = "\(winner.name) 生命值率先積滿 \(winningHealth) 點，五行大成，登峰造極！"
            return
        }
        
        // 檢查存活人數
        let alivePlayers = players.filter { $0.isAlive }
        
        // 若在人機對戰中，人類玩家出局
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
        
        // 若僅剩 1 人生還
        if alivePlayers.count == 1 {
            let survivor = alivePlayers[0]
            isGameOver = true
            winnerName = survivor.name
            gameOverTitle = "🏆 \(survivor.name) 獲勝！"
            gameOverDetail = "其餘對手皆已出局，\(survivor.name) 成為唯一生還的武林至尊！"
            return
        }
        
        // 全員同時陣亡
        if alivePlayers.isEmpty {
            isGameOver = true
            winnerName = nil
            gameOverTitle = "⚖️ 同歸於盡！"
            gameOverDetail = "所有參戰者生命值同時歸零，平手作收！"
            return
        }
    }
    
    // MARK: - 對戰歷史記錄結算
    
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
    
    /// 清除所有歷史對戰記錄
    func clearBattleHistory() {
        battleHistory.removeAll()
    }
    
    /// 進入下一回合
    func nextRound() {
        guard !isGameOver else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            roundNumber += 1
            isRevealed = false
            showClashTheater = false
            activeClashIndex = 0
            lastRecord = nil
            
            for i in 0..<players.count {
                players[i].selection = nil
                players[i].isLocked = false
            }
            
            // 找出第一位未淘汰的玩家
            let firstAliveIndex = players.firstIndex(where: { $0.isAlive }) ?? 0
            passTurnStep = .choosing(playerIndex: firstAliveIndex)
            
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
