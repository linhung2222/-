//
//  FullScreenTheaterView.swift
//  五行拳
//
//  全螢幕對決生剋劇院視圖模組
//  整合二階段動態演出：
//    第一階段（.punching）：雙方 SpriteKit 蓄力衝拳與拳招特效碰撞
//    第二階段（.interacting）：五行相生／相剋之電影感全螢幕動畫與血量結算
//

import SwiftUI

/// 全螢幕對決劇院演出的二階段狀態列舉
enum ClashTheaterPhase: String, CaseIterable, Identifiable {
    /// 階段一：出拳發勁與雙方拳意對峙衝刺
    case punching = "出拳發勁"
    /// 階段二：五行相生相剋結算演出與數值增減
    case interacting = "生剋結果"
    
    /// 遵循 Identifiable 協定之唯一識別碼
    var id: String { rawValue }
}

/// 全螢幕對決生剋劇院容器視圖（Full-Screen Clash Theater View）
/// 串聯 SpriteKit 實體粒子拳招展示與 SwiftUI 幾何相生相剋動畫，提供沉浸式武術對戰視聽體驗
struct FullScreenTheaterView: View {
    /// 當前回合所有發生的兩兩五行生剋互動陣列
    let interactions: [PairwiseInteraction]
    /// 當前回合各玩家的出拳與結算狀態陣列
    let actions: [PlayerRoundAction]
    /// 目前展示的生剋互動索引（雙向綁定）
    @Binding var activeIndex: Int
    /// 控制劇院視圖顯示與關閉的布林值（雙向綁定）
    @Binding var isPresented: Bool
    /// 是否已達決勝（終局）狀態
    var isGameOver: Bool = false
    /// 終局獲勝者名稱
    var winnerName: String? = nil
    /// 終局主標題
    var gameOverTitle: String = ""
    /// 終局詳細說明文字
    var gameOverDetail: String = ""
    /// 進入下一回合的回呼閉包（Closure）
    var onNextRound: (() -> Void)? = nil
    /// 重新開始新賽局的回呼閉包
    var onRestartGame: (() -> Void)? = nil
    
    /// 當前演出階段（出拳發勁 或 生剋結果）
    @State private var phase: ClashTheaterPhase = .punching
    /// 畫面轉場瞬間的白光衝擊閃爍旗標
    @State private var screenFlash: Bool = false
    /// 自動推進階段之非同步計時器任務（Task）
    @State private var autoTimerTask: Task<Void, Never>? = nil
    
    /// 計算屬性：依據 activeIndex 取得當前聚焦展示的兩兩生剋物件
    private var currentInteraction: PairwiseInteraction? {
        guard !interactions.isEmpty, interactions.indices.contains(activeIndex) else { return nil }
        return interactions[activeIndex]
    }
    
    /// 計算屬性：左側對決者（施生方／主攻方）的名稱與五行元素
    private var sourceFighter: (name: String, element: FiveElement) {
        if let item = currentInteraction {
            return (item.sourceName, item.sourceElement)
        }
        if actions.count >= 1 {
            return (actions[0].playerName, actions[0].choice)
        }
        return ("玩家", .water)
    }
    
    /// 計算屬性：右側對決者（受生方／受擊方）的名稱與五行元素
    private var targetFighter: (name: String, element: FiveElement) {
        if let item = currentInteraction {
            return (item.targetName, item.targetElement)
        }
        if actions.count >= 2 {
            return (actions[1].playerName, actions[1].choice)
        }
        return ("對手", sourceFighter.element)
    }
    
    var body: some View {
        ZStack {
            // 背景深色玄幻靈氣氛圍流光
            ambientBackground
                .ignoresSafeArea()
            
            if phase == .punching {
                // 階段一：各自出拳發勁展示（基於 SpriteKit 的衝拳碰撞場景）
                FullScreenPunchShowdownView(
                    sourceName: sourceFighter.name,
                    sourceElement: sourceFighter.element,
                    targetName: targetFighter.name,
                    targetElement: targetFighter.element,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                        }
                    },
                    onClash: {
                        // 玩家手動點擊提早交鋒衝擊
                        triggerClashFlash()
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .scale(scale: 1.05).combined(with: .opacity)
                ))
            } else {
                // 階段二：相生相剋全螢幕動態電影感演出與戰報控制面板
                FullScreenClashView(
                    interactions: interactions,
                    actions: actions,
                    activeIndex: $activeIndex,
                    isPresented: $isPresented,
                    onNextRound: onNextRound
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            
            // 兩階段交鋒轉場瞬間的白光爆炸閃屏
            if screenFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            startPunchToClashSequence()
        }
        .onChange(of: activeIndex) { _, _ in
            startPunchToClashSequence()
        }
    }
    
    // MARK: - 背景流光氛圍
    
    /// 依據雙方五行主色調在畫布對角線渲染柔和的動態光暈
    private var ambientBackground: some View {
        ZStack {
            Color.black
            
            // 左上方：攻方五行色調光暈
            RadialGradient(
                colors: [sourceFighter.element.primaryColor.opacity(0.35), Color.black],
                center: .topLeading,
                startRadius: 60,
                endRadius: 450
            )
            
            // 右下方：受擊方五行色調光暈
            RadialGradient(
                colors: [targetFighter.element.primaryColor.opacity(0.35), Color.black],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 450
            )
        }
    }
    
    // MARK: - 動畫排程推進邏輯
    
    /// 啟動自「出拳發勁」過渡至「生剋結果」的排程邏輯
    private func startPunchToClashSequence() {
        // 取消先前可能存在的定時任務
        autoTimerTask?.cancel()
        phase = .punching
        
        // 延遲 2.4 秒後自動交鋒轉場至生剋結果（預留足夠時間觀賞 SpriteKit 出拳蓄力、發勁突擊與碰撞光效）
        autoTimerTask = Task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                triggerClashFlash()
            }
        }
    }
    
    /// 觸發劇烈碰撞閃白並切換至階段二（生剋結果展示）
    private func triggerClashFlash() {
        autoTimerTask?.cancel()
        withAnimation(.easeOut(duration: 0.18)) {
            screenFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeInOut(duration: 0.25)) {
                phase = .interacting
                screenFlash = false
            }
        }
    }
}
