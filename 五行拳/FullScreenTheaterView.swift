//
//  FullScreenTheaterView.swift
//  五行拳
//

import SwiftUI

enum ClashTheaterPhase: String, CaseIterable, Identifiable {
    case punching = "出拳發勁"
    case interacting = "生剋結果"
    var id: String { rawValue }
}

/// 全螢幕對決生剋劇院容器（整合各拳 SpriteKit 出拳動畫與相生相剋互動結果）
struct FullScreenTheaterView: View {
    let interactions: [PairwiseInteraction]
    let actions: [PlayerRoundAction]
    @Binding var activeIndex: Int
    @Binding var isPresented: Bool
    var isGameOver: Bool = false
    var winnerName: String? = nil
    var gameOverTitle: String = ""
    var gameOverDetail: String = ""
    var onNextRound: (() -> Void)? = nil
    var onRestartGame: (() -> Void)? = nil
    
    @State private var phase: ClashTheaterPhase = .punching
    @State private var screenFlash: Bool = false
    @State private var autoTimerTask: Task<Void, Never>? = nil
    
    private var currentInteraction: PairwiseInteraction? {
        guard !interactions.isEmpty, interactions.indices.contains(activeIndex) else { return nil }
        return interactions[activeIndex]
    }
    
    private var sourceFighter: (name: String, element: FiveElement) {
        if let item = currentInteraction {
            return (item.sourceName, item.sourceElement)
        }
        if actions.count >= 1 {
            return (actions[0].playerName, actions[0].choice)
        }
        return ("玩家", .water)
    }
    
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
            // 背景深色玄幻氛圍
            ambientBackground
                .ignoresSafeArea()
            
            if phase == .punching {
                // 階段一：各自出拳展示 (Punch Showdown via SpriteKit)
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
                        triggerClashFlash()
                    }
                )
                .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 1.05).combined(with: .opacity)))
            } else {
                // 階段二：相生相剋全螢幕動態演出
                FullScreenClashView(
                    interactions: interactions,
                    actions: actions,
                    activeIndex: $activeIndex,
                    isPresented: $isPresented,
                    onNextRound: onNextRound
                )
                .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
            }
            
            // 轉場爆裂白光
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
    private var ambientBackground: some View {
        ZStack {
            Color.black
            
            RadialGradient(
                colors: [sourceFighter.element.primaryColor.opacity(0.35), Color.black],
                center: .topLeading,
                startRadius: 60,
                endRadius: 450
            )
            
            RadialGradient(
                colors: [targetFighter.element.primaryColor.opacity(0.35), Color.black],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 450
            )
        }
    }
    
    // MARK: - 動畫排程推進
    private func startPunchToClashSequence() {
        autoTimerTask?.cancel()
        phase = .punching
        
        // 延遲 2.4 秒後自動交鋒轉場至生剋結果 (預留 SpriteKit 出拳蓄力、發勁突擊與碰撞足夠時間)
        autoTimerTask = Task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                triggerClashFlash()
            }
        }
    }
    
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
