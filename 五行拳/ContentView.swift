//
//  ContentView.swift
//  五行拳
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = FiveElementsGameViewModel()
    
    @State private var showRulesSheet = false
    @State private var showHistorySheet = false
    @State private var showResetConfirm = false
    @State private var showCover = true
    
    var body: some View {
        @Bindable var vm = viewModel
        
        ZStack {
            NavigationStack {
                ZStack {
                    Color.secondary.opacity(0.06)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        headerSection
                            .padding(.horizontal)
                            .padding(.top, 6)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Group {
                            switch viewModel.gameMode {
                            case .vsAI:
                                vsAIView
                            case .pvpPass:
                                pvpPassView
                            case .pvpTogether:
                                pvpTogetherView
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle("五行拳")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            showRulesSheet = true
                        } label: {
                            Label("生剋圖解", systemImage: "questionmark.circle")
                                .font(.elementChinese(size: 14))
                        }
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 12) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showCover = true
                                }
                            } label: {
                                Image(systemName: "photo.artframe")
                            }
                            .help("返回遊戲封面")
                            
                            Button {
                                showHistorySheet = true
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                            .help("對戰記錄")
                            
                            Button {
                                showResetConfirm = true
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .help("重開遊戲")
                        }
                    }
                }
                .sheet(isPresented: $showRulesSheet) {
                    RulesSheetView()
                }
                .sheet(isPresented: $showHistorySheet) {
                    HistorySheetView(viewModel: viewModel)
                }
                .alert("重新開始遊戲", isPresented: $showResetConfirm) {
                    Button("重新開始", role: .destructive) {
                        viewModel.restartGame()
                    }
                    Button("取消", role: .cancel) {}
                } message: {
                    Text("確定要回復為初始 2 點生命值與獲勝 5 點生命值，開啟全新對決嗎？")
                }
                .alert(viewModel.gameOverTitle, isPresented: $vm.isGameOver) {
                    Button("再戰一局", role: .none) {
                        viewModel.resetGame()
                    }
                } message: {
                    Text(viewModel.gameOverDetail)
                }
            }
            #if os(macOS)
            .frame(minWidth: 520, idealWidth: 580, minHeight: 720, idealHeight: 780)
            #endif
            
            // MARK: - 全螢幕出拳發勁與相生相剋劇院演出覆蓋層
            if viewModel.showClashTheater, let record = viewModel.lastRecord {
                FullScreenTheaterView(
                    interactions: record.interactions,
                    actions: record.actions,
                    activeIndex: $vm.activeClashIndex,
                    isPresented: $vm.showClashTheater,
                    isGameOver: viewModel.isGameOver,
                    winnerName: viewModel.winnerName,
                    gameOverTitle: viewModel.gameOverTitle,
                    gameOverDetail: viewModel.gameOverDetail,
                    onNextRound: {
                        viewModel.showClashTheater = false
                        viewModel.nextRound()
                    },
                    onRestartGame: {
                        viewModel.showClashTheater = false
                        viewModel.restartGame()
                    }
                )
                .transition(.opacity)
                .zIndex(999)
            }
            
            // MARK: - 遊戲啟動封面 (Splash Cover Screen)
            if showCover {
                GameCoverView(onStartGame: {
                    withAnimation(.easeInOut(duration: 0.85)) {
                        showCover = false
                    }
                })
                .transition(.opacity)
                .zIndex(1000)
            }
        }
    }
    
    // MARK: - 頂部看板
    private var headerSection: some View {
        @Bindable var vm = viewModel
        
        return VStack(spacing: 8) {
            // 模式選擇
            Picker("遊戲模式", selection: $vm.gameMode) {
                ForEach(GameMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            // 人數選擇（人機對戰與輪流暗選支援 2 ~ 4 人）
            if viewModel.gameMode != .pvpTogether {
                HStack(spacing: 8) {
                    Label("玩家人數:", systemImage: "person.3.fill")
                        .font(.elementChinese(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Picker("人數", selection: $vm.playerCount) {
                        if viewModel.gameMode == .vsAI {
                            Text("2 人 (1v1)").tag(2)
                            Text("3 人 (1v2 AI)").tag(3)
                            Text("4 人 (1v3 AI)").tag(4)
                        } else {
                            Text("2 人").tag(2)
                            Text("3 人").tag(3)
                            Text("4 人").tag(4)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            // 生命值設定（所有模式皆支援自由調整初始生命值與獲勝生命值）
            HStack(spacing: 10) {
                // 初始生命值調整
                HStack(spacing: 6) {
                    Label("初始生命", systemImage: "heart.fill")
                        .font(.elementChinese(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    Spacer()
                    
                    Button {
                        if viewModel.initialHealth > 2 {
                            viewModel.initialHealth -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.initialHealth > 2 ? .pink : .secondary.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.initialHealth <= 2)
                    
                    Text("\(viewModel.initialHealth)")
                        .font(.elemental(size: 14))
                        .foregroundColor(.primary)
                        .frame(minWidth: 16)
                    
                    Button {
                        if viewModel.initialHealth < viewModel.maxInitialHealth {
                            viewModel.initialHealth += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.initialHealth < viewModel.maxInitialHealth ? .pink : .secondary.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.initialHealth >= viewModel.maxInitialHealth)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // 獲勝生命值調整
                HStack(spacing: 6) {
                    Label("獲勝生命", systemImage: "trophy.fill")
                        .font(.elementChinese(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button {
                        if viewModel.winningHealth > 4 {
                            viewModel.winningHealth -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.winningHealth > 4 ? .orange : .secondary.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.winningHealth <= 4)
                    
                    Text("\(viewModel.winningHealth)")
                        .font(.elemental(size: 14))
                        .foregroundColor(.primary)
                        .frame(minWidth: 16)
                    
                    Button {
                        if viewModel.winningHealth < 10 {
                            viewModel.winningHealth += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.winningHealth < 10 ? .orange : .secondary.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.winningHealth >= 10)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
            
            // 回合指示標籤
            HStack {
                Text("第 \(viewModel.roundNumber) 回合")
                    .font(.elementChinese(size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(viewModel.gameMode.subtitle)
                    .font(.elementChinese(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // 玩家生命值看板 (支援 2 ~ 4 人網格/橫排排版)
            if viewModel.players.count <= 2 {
                HStack(spacing: 10) {
                    ForEach(viewModel.players) { player in
                        HealthBarView(
                            currentHealth: player.health,
                            maxHealth: viewModel.winningHealth,
                            playerName: player.name,
                            isAI: player.isAI,
                            isEliminated: player.isEliminated,
                            compact: false
                        )
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 6) {
                    ForEach(viewModel.players) { player in
                        HealthBarView(
                            currentHealth: player.health,
                            maxHealth: viewModel.winningHealth,
                            playerName: player.name,
                            isAI: player.isAI,
                            isEliminated: player.isEliminated,
                            compact: true
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - 模式 1：人機切磋 (1 人 vs 1~3 AI)
    private var vsAIView: some View {
        let humanPlayer = viewModel.players.first(where: { !$0.isAI })
        let aiPlayers = viewModel.players.filter { $0.isAI }
        let aiCardWidth: CGFloat = aiPlayers.count == 1 ? 95 : (aiPlayers.count == 2 ? 85 : 74)
        let aiCardHeight: CGFloat = aiPlayers.count == 1 ? 125 : (aiPlayers.count == 2 ? 112 : 98)
        
        return VStack(spacing: 10) {
            // 上方：AI 對手牌面區
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "cpu")
                        .font(.caption)
                        .foregroundColor(.purple)
                    Text("AI 對手（\(aiPlayers.filter { $0.isAlive }.count) 存活）")
                        .font(.elementChinese(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: aiPlayers.count > 2 ? 8 : 16) {
                    ForEach(aiPlayers) { ai in
                        ElementCardView(
                            element: ai.selection,
                            title: ai.name,
                            isHidden: !viewModel.isRevealed,
                            isEliminated: ai.isEliminated,
                            hpChange: viewModel.lastRecord?.actions.first(where: { $0.playerId == ai.id })?.hpChange,
                            width: aiCardWidth,
                            height: aiCardHeight
                        )
                    }
                }
            }
            .padding(.top, 4)
            
            // 中間：VS 與戰況提示
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                Text("VS")
                    .font(.elemental(size: 16))
                    .foregroundColor(.secondary)
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
            }
            .padding(.horizontal, 24)
            
            announcementBanner
            
            Spacer()
            
            // 下方：人類玩家卡片與出拳操作區
            if let human = humanPlayer {
                VStack(spacing: 12) {
                    ElementCardView(
                        element: human.selection,
                        title: human.name,
                        isHidden: false,
                        isEliminated: human.isEliminated,
                        hpChange: viewModel.lastRecord?.actions.first(where: { $0.playerId == human.id })?.hpChange,
                        width: 88,
                        height: 114
                    )
                    
                    if !viewModel.isRevealed {
                        Text("請選擇您要施展的五行拳招式")
                            .font(.elementChinese(size: 14))
                            .foregroundColor(.secondary)
                        
                        fiveElementButtons(selected: human.selection) { el in
                            viewModel.playerChooseVsAI(el)
                        }
                    } else {
                        Button {
                            viewModel.nextRound()
                        } label: {
                            HStack {
                                Text("再下一城（下一回合）")
                                    .font(.elementChinese(size: 16))
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                            .shadow(radius: 4)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - 模式 2：同機輪流暗選模式 (2 ~ 4 人 Pass & Play)
    private var pvpPassView: some View {
        let cardWidth: CGFloat = viewModel.playerCount == 2 ? 95 : (viewModel.playerCount == 3 ? 84 : 72)
        let cardHeight: CGFloat = viewModel.playerCount == 2 ? 125 : (viewModel.playerCount == 3 ? 112 : 98)
        
        return VStack(spacing: 12) {
            // 回合對決牌面展示區
            HStack(spacing: viewModel.playerCount > 2 ? 8 : 20) {
                ForEach(viewModel.players) { player in
                    ElementCardView(
                        element: player.selection,
                        title: player.name,
                        isHidden: !viewModel.isRevealed,
                        isEliminated: player.isEliminated,
                        hpChange: viewModel.lastRecord?.actions.first(where: { $0.playerId == player.id })?.hpChange,
                        width: cardWidth,
                        height: cardHeight
                    )
                }
            }
            .padding(.top, 8)
            
            announcementBanner
            
            Spacer()
            
            // 依照輪流流程顯示控制項
            switch viewModel.passTurnStep {
            case .choosing(let playerIndex):
                if viewModel.players.indices.contains(playerIndex) {
                    let currentPlayer = viewModel.players[playerIndex]
                    VStack(spacing: 12) {
                        Text("【\(currentPlayer.name)】請暗自選出五行拳")
                            .font(.elementChinese(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        fiveElementButtons(selected: currentPlayer.selection) { el in
                            viewModel.passPlayerChoose(playerIndex: playerIndex, element: el)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
            case .waitingNextPlayer(let nextIndex):
                if viewModel.players.indices.contains(nextIndex) {
                    let nextPlayer = viewModel.players[nextIndex]
                    VStack(spacing: 16) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        
                        Text("請將設備交給【\(nextPlayer.name)】")
                            .font(.elementChinese(size: 18))
                            .fontWeight(.bold)
                        
                        Text("請勿偷看其他玩家出拳，保持公平。")
                            .font(.elementChinese(size: 13))
                            .foregroundColor(.secondary)
                        
                        Button {
                            viewModel.startNextPassPlayerTurn(playerIndex: nextIndex)
                        } label: {
                            Text("【\(nextPlayer.name)】準備就緒，開始選拳")
                                .font(.elementChinese(size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.bottom, 30)
                }
                
            case .revealed:
                Button {
                    viewModel.nextRound()
                } label: {
                    HStack {
                        Text("進入下一回合")
                            .font(.elementChinese(size: 16))
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(LinearGradient(colors: [.indigo, .blue], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
                    .shadow(radius: 4)
                }
                .padding(.bottom, 25)
            }
        }
    }
    
    // MARK: - 模式 3：雙人同屏面對面對決 (Face-to-Face)
    private var pvpTogetherView: some View {
        VStack(spacing: 8) {
            // 上半部：玩家二操作區 (倒轉 180 度)
            if viewModel.players.count >= 2 {
                let p2 = viewModel.players[1]
                VStack(spacing: 6) {
                    HStack {
                        Text("玩家二選拳")
                            .font(.elementChinese(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Spacer()
                        if p2.isLocked {
                            Label("已鎖定", systemImage: "checkmark.seal.fill")
                                .font(.elementChinese(size: 11))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 10) {
                        ForEach(FiveElement.allCases) { el in
                            ElementButton(
                                element: el,
                                isSelected: p2.selection == el,
                                size: 46
                            ) {
                                if !viewModel.isRevealed {
                                    viewModel.pvpTogetherP2Choose(el)
                                }
                            }
                        }
                    }
                }
                .rotationEffect(.degrees(180))
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.12))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            
            // 中央對決牌面
            if viewModel.players.count >= 2 {
                let p1 = viewModel.players[0]
                let p2 = viewModel.players[1]
                
                HStack(spacing: 24) {
                    ElementCardView(
                        element: p1.selection,
                        title: p1.name,
                        isHidden: !viewModel.isRevealed,
                        hpChange: viewModel.lastRecord?.actions.first(where: { $0.playerId == p1.id })?.hpChange,
                        width: 90,
                        height: 120
                    )
                    
                    Text("VS")
                        .font(.elemental(size: 20))
                        .foregroundColor(.secondary)
                    
                    ElementCardView(
                        element: p2.selection,
                        title: p2.name,
                        isHidden: !viewModel.isRevealed,
                        hpChange: viewModel.lastRecord?.actions.first(where: { $0.playerId == p2.id })?.hpChange,
                        width: 90,
                        height: 120
                    )
                }
                .padding(.vertical, 4)
            }
            
            announcementBanner
            
            if viewModel.isRevealed {
                Button {
                    viewModel.nextRound()
                } label: {
                    Text("下一回合")
                        .font(.elementChinese(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.vertical, 2)
            }
            
            Spacer()
            
            // 下半部：玩家一操作區 (正向)
            if viewModel.players.count >= 1 {
                let p1 = viewModel.players[0]
                VStack(spacing: 6) {
                    HStack {
                        Text("玩家一選拳")
                            .font(.elementChinese(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Spacer()
                        if p1.isLocked {
                            Label("已鎖定", systemImage: "checkmark.seal.fill")
                                .font(.elementChinese(size: 11))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 10) {
                        ForEach(FiveElement.allCases) { el in
                            ElementButton(
                                element: el,
                                isSelected: p1.selection == el,
                                size: 46
                            ) {
                                if !viewModel.isRevealed {
                                    viewModel.pvpTogetherP1Choose(el)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.12))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - 共用元件：五行按鈕排
    private func fiveElementButtons(selected: FiveElement?, onSelect: @escaping (FiveElement) -> Void) -> some View {
        HStack(spacing: 10) {
            ForEach(FiveElement.allCases) { el in
                ElementButton(
                    element: el,
                    isSelected: selected == el,
                    size: 54
                ) {
                    onSelect(el)
                }
            }
        }
    }
    
    // MARK: - 戰況資訊卡
    private var announcementBanner: some View {
        VStack(spacing: 6) {
            Text(viewModel.announcementText)
                .font(.elementChinese(size: 13))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            if viewModel.isRevealed, viewModel.lastRecord != nil {
                Button {
                    viewModel.activeClashIndex = 0
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.showClashTheater = true
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                        Text("觀看全螢幕出拳與生剋動畫")
                            .font(.elementChinese(size: 12))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.16))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.12))
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - 規則說明彈窗視圖
struct RulesSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    WuXingDiagramView()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("【遊戲規則說明】")
                            .font(.elementChinese(size: 16))
                            .foregroundColor(.primary)
                        
                        ruleRow(
                            icon: "person.3.fill",
                            title: "人數上限與生命值",
                            desc: "支援 2 ~ 4 人混戰（包含 1 位玩家對決最多 3 位 AI 禪師）！參戰者初始生命值（最低 2，最高為獲勝生命值一半且捨小數）與獲勝生命值（4 ~ 10）皆可在各模式自由調整，生命值歸零則出局淘汰。"
                        )
                        
                        ruleRow(
                            icon: "arrow.triangle.swap",
                            title: "多人同時兩兩結算",
                            desc: "每回合所有在場存活者同時出拳，系統會自動兩兩比對彼此的五行關係：\n• 相生：被生的一方生命值 +1（受天地滋養）。\n• 相剋：被剋的一方生命值 -1（招式受制受損）。\n• 同拳：平手，不影響生命值。"
                        )
                        
                        ruleRow(
                            icon: "trophy.fill",
                            title: "勝負判定",
                            desc: "• 任何玩家生命值率先積滿設定的獲勝生命值，即刻「五行大成」奪冠！\n• 生命值扣至 0 者淘汰出局，最後唯一的生還者獲得勝利！"
                        )
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(14)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("五行拳秘笈")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(.elementChinese(size: 15))
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 520)
        #endif
    }
    
    private func ruleRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.elementChinese(size: 14))
                    .fontWeight(.bold)
                Text(desc)
                    .font(.elementChinese(size: 12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - 對戰歷史記錄清單視圖
struct HistorySheetView: View {
    @Bindable var viewModel: FiveElementsGameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirm: Bool = false
    @State private var expandedBattleIds: Set<UUID> = []
    
    init(viewModel: FiveElementsGameViewModel) {
        self.viewModel = viewModel
    }
    
    init(history: [RoundRecord] = []) {
        let vm = FiveElementsGameViewModel()
        vm.history = history
        self.viewModel = vm
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.battleHistory.isEmpty && viewModel.history.isEmpty {
                    ContentUnavailableView(
                        "尚無對戰記錄",
                        systemImage: "clock",
                        description: Text("完成出拳對決後將在此記錄各場對戰結果與詳細戰況。")
                    )
                } else {
                    List {
                        // 歷史對戰結果（已結算完成之戰局）
                        if !viewModel.battleHistory.isEmpty {
                            Section {
                                ForEach(viewModel.battleHistory) { battle in
                                    battleCard(battle)
                                }
                            } header: {
                                HStack {
                                    Label("已完結對戰記錄 (\(viewModel.battleHistory.count) 場)", systemImage: "trophy.fill")
                                        .font(.elementChinese(size: 13))
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        
                        // 當前正在進行的對局
                        if !viewModel.history.isEmpty && !viewModel.isGameOver {
                            Section {
                                ForEach(viewModel.history) { record in
                                    roundRow(record)
                                }
                            } header: {
                                HStack {
                                    Label("當前對決（第 \(viewModel.roundNumber) 回合進行中）", systemImage: "hourglass")
                                        .font(.elementChinese(size: 13))
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("對戰記錄")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.battleHistory.isEmpty {
                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            Label("清除記錄", systemImage: "trash")
                                .font(.elementChinese(size: 14))
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("關閉") {
                        dismiss()
                    }
                    .font(.elementChinese(size: 15))
                }
            }
            .confirmationDialog("確定要清除所有歷史對戰記錄嗎？", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("清除所有記錄", role: .destructive) {
                    viewModel.clearBattleHistory()
                }
                Button("取消", role: .cancel) {}
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 540)
        #endif
    }
    
    // MARK: - 整場對戰記錄卡片
    @ViewBuilder
    private func battleCard(_ battle: BattleRecord) -> some View {
        let isExpanded = expandedBattleIds.contains(battle.id)
        
        VStack(alignment: .leading, spacing: 10) {
            // 對戰結果標頭（勝負徽章、勝負標題、日期時間）
            HStack(spacing: 8) {
                outcomeBadge(battle.outcome)
                
                Text(battle.resultTitle)
                    .font(.elementChinese(size: 16))
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(battle.date.formatted(date: .numeric, time: .shortened))
                    .font(.elementChinese(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // 模式與規則資訊標籤
            HStack(spacing: 6) {
                Label(battle.gameMode.rawValue, systemImage: "gamecontroller.fill")
                    .font(.elementChinese(size: 10))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
                
                Text("共 \(battle.totalRounds) 回合")
                    .font(.elementChinese(size: 10))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.elementChinese(size: 10))
                    .foregroundColor(.secondary)
                
                Text("初始 \(battle.initialHealth) / 獲勝 \(battle.winningHealth) 血")
                    .font(.elementChinese(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // 結果詳情說明
            Text(battle.resultDetail)
                .font(.elementChinese(size: 12))
                .foregroundColor(.secondary)
            
            // 參戰者最終生命值狀態
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(battle.finalPlayers) { player in
                        HStack(spacing: 4) {
                            Text(player.name)
                                .font(.elementChinese(size: 11))
                                .fontWeight(.bold)
                            
                            if player.health >= battle.winningHealth {
                                Text("👑 滿血獲勝")
                                    .font(.elementChinese(size: 10))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.yellow)
                            } else if player.health <= 0 {
                                Text("💀 出局")
                                    .font(.elementChinese(size: 10))
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            } else {
                                Text("\(player.health) ❤️")
                                    .font(.elemental(size: 11))
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(player.name == battle.winnerName ? Color.yellow.opacity(0.18) : Color.secondary.opacity(0.08))
                        )
                    }
                }
            }
            
            // 展開/收合回合明細按鈕
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded {
                        expandedBattleIds.remove(battle.id)
                    } else {
                        expandedBattleIds.insert(battle.id)
                    }
                }
            } label: {
                HStack {
                    Text(isExpanded ? "收合各回合戰況" : "查看各回合戰況 (\(battle.rounds.count) 回合)")
                        .font(.elementChinese(size: 12))
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                }
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            
            // 展開時顯示各回合明細
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    ForEach(battle.rounds.reversed()) { round in
                        roundRow(round)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 勝負結果標籤
    @ViewBuilder
    private func outcomeBadge(_ outcome: BattleOutcome) -> some View {
        switch outcome {
        case .win:
            Text("獲勝")
                .font(.elementChinese(size: 11))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green)
                .clipShape(Capsule())
        case .defeat:
            Text("戰敗")
                .font(.elementChinese(size: 11))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red)
                .clipShape(Capsule())
        case .draw:
            Text("平手")
                .font(.elementChinese(size: 11))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary)
                .clipShape(Capsule())
        }
    }
    
    // MARK: - 單回合記錄行
    @ViewBuilder
    private func roundRow(_ record: RoundRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("第 \(record.roundNumber) 回合")
                    .font(.elementChinese(size: 14))
                    .fontWeight(.bold)
                
                if record.isGameOverRound, let res = record.battleResultTitle {
                    Text(res)
                        .font(.elementChinese(size: 11))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            // 各玩家出拳與血量標籤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(record.actions) { action in
                        HStack(spacing: 4) {
                            Text(action.playerName)
                                .font(.elementChinese(size: 11))
                                .fontWeight(.bold)
                            
                            Text(action.choice.rawValue)
                                .font(.elementChinese(size: 12))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(action.choice.primaryColor)
                                .clipShape(Capsule())
                            
                            Text("\(action.hpChange >= 0 ? "+\(action.hpChange)" : "\(action.hpChange)")")
                                .font(.elemental(size: 11))
                                .fontWeight(.bold)
                                .foregroundColor(action.hpChange > 0 ? .green : (action.hpChange < 0 ? .red : .secondary))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            
            // 戰況總結
            Text(record.summary)
                .font(.elementChinese(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ContentView()
}
