//
//  AnimationViews.swift
//  五行拳
//

import SwiftUI

// MARK: - 五行專屬出拳動態特效 (金：大刀一揮、木：樹木生長、水：大水沖刷、火：火焰噴發、土：泥土堆疊)

struct ElementPunchEffectView: View {
    let element: FiveElement
    var compact: Bool = false
    
    @State private var animPhase: CGFloat = 0
    @State private var pulse: Bool = false
    @State private var particlesActive: Bool = false
    
    var body: some View {
        ZStack {
            switch element {
            case .metal:
                metalBladeSlashView
            case .wood:
                woodGrowthView
            case .water:
                waterSurgeView
            case .fire:
                fireEruptionView
            case .earth:
                earthStackView
            }
            
            // 特效名稱與詩號標籤
            VStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: element.iconName)
                        .font(.caption2)
                    Text(element.attackName)
                        .font(.elementChinese(size: compact ? 12 : 14))
                }
                .foregroundColor(.white)
                .padding(.horizontal, compact ? 10 : 14)
                .padding(.vertical, compact ? 4 : 6)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [element.primaryColor, element.primaryColor.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: element.primaryColor.opacity(0.6), radius: 6)
                )
                .padding(.bottom, compact ? 4 : 8)
                .scaleEffect(pulse ? 1.05 : 0.95)
            }
        }
        .frame(width: compact ? 140 : 200, height: compact ? 120 : 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(element.primaryColor.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(element.primaryColor.opacity(0.3), lineWidth: 1.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                animPhase = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeOut(duration: 0.7)) {
                particlesActive = true
            }
        }
    }
    
    // MARK: 1. 金：大刀一揮
    private var metalBladeSlashView: some View {
        ZStack {
            // 背景金芒衝擊光圈
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    ),
                    lineWidth: 6
                )
                .scaleEffect(animPhase > 0.3 ? 1.2 : 0.3)
                .opacity(animPhase > 0.3 ? 0.8 : 0)
            
            // 弧形刀光斬痕 (Slash Arc Path)
            Path { path in
                path.addArc(
                    center: CGPoint(x: compact ? 70 : 100, y: compact ? 60 : 80),
                    radius: compact ? 42 : 58,
                    startAngle: .degrees(-80),
                    endAngle: .degrees(40),
                    clockwise: false
                )
            }
            .stroke(
                LinearGradient(
                    colors: [.clear, Color.white, Color(red: 1, green: 0.9, blue: 0.4), Color.orange, .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: compact ? 4 : 6, lineCap: .round)
            )
            .scaleEffect(animPhase > 0.2 ? 1.05 : 0.2)
            .opacity(animPhase > 0.2 ? 1.0 : 0.0)
            .shadow(color: .yellow, radius: 8)
            
            // 金色大刀 (Broadsword)
            VStack(spacing: 0) {
                // 刀尖與刀身
                ZStack(alignment: .top) {
                    // 刀脊金色光澤
                    Path { p in
                        p.move(to: CGPoint(x: 10, y: 0))
                        p.addLine(to: CGPoint(x: 20, y: 55))
                        p.addLine(to: CGPoint(x: 2, y: 55))
                        p.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 1.0, green: 0.85, blue: 0.3), Color(red: 0.8, green: 0.6, blue: 0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // 刀刃高光流動
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 2, height: 45)
                        .offset(x: 4, y: 5)
                }
                .frame(width: 22, height: 55)
                
                // 護手
                RoundedRectangle(cornerRadius: 3)
                    .fill(LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 32, height: 7)
                    .shadow(radius: 2)
                
                // 刀柄與刀穗
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.35, green: 0.2, blue: 0.1))
                    .frame(width: 7, height: 18)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 7, height: 7)
            }
            .shadow(color: Color.yellow.opacity(0.8), radius: 5)
            .rotationEffect(.degrees(animPhase > 0.1 ? 30 : -55))
            .offset(x: animPhase > 0.1 ? 15 : -25, y: animPhase > 0.1 ? 5 : -15)
            
            // 刀鋒火星散落
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: CGFloat(i % 3 + 3), height: CGFloat(i % 3 + 3))
                    .offset(
                        x: particlesActive ? CGFloat(cos(Double(i) * 1.0) * (compact ? 35 : 50)) : 0,
                        y: particlesActive ? CGFloat(sin(Double(i) * 1.0) * (compact ? 30 : 45)) : 0
                    )
                    .opacity(particlesActive ? 0.9 : 0)
            }
        }
    }
    
    // MARK: 2. 木：樹木生長
    private var woodGrowthView: some View {
        ZStack {
            // 靈氣自然綠色光環
            Circle()
                .fill(RadialGradient(colors: [Color.green.opacity(0.25), .clear], center: .center, startRadius: 5, endRadius: 65))
                .scaleEffect(animPhase > 0.2 ? 1.1 : 0.4)
            
            // 樹幹向上拔高生長
            VStack(spacing: 0) {
                Spacer()
                
                // 樹冠枝葉簇
                ZStack {
                    // 主樹冠
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.35, green: 0.85, blue: 0.45), Color(red: 0.15, green: 0.6, blue: 0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: compact ? 48 : 64, height: compact ? 42 : 56)
                        .scaleEffect(animPhase > 0.4 ? 1.0 : 0.1, anchor: .bottom)
                    
                    // 嫩葉向外綻放
                    ForEach(0..<6, id: \.self) { i in
                        Image(systemName: "leaf.fill")
                            .font(.system(size: compact ? 13 : 17))
                            .foregroundColor(Color(red: 0.45, green: 0.95, blue: 0.5))
                            .rotationEffect(.degrees(Double(i) * 60 + (pulse ? 10 : -10)))
                            .offset(
                                x: animPhase > 0.5 ? CGFloat(cos(Double(i) * 1.05) * (compact ? 24 : 32)) : 0,
                                y: animPhase > 0.5 ? CGFloat(sin(Double(i) * 1.05) * (compact ? 20 : 28)) : 0
                            )
                            .scaleEffect(animPhase > 0.5 ? 1.0 : 0.0)
                    }
                }
                
                // 樹幹
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.45, green: 0.28, blue: 0.15), Color(red: 0.3, green: 0.18, blue: 0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: compact ? 12 : 16, height: animPhase > 0.1 ? (compact ? 36 : 48) : 4)
                    .scaleEffect(y: animPhase, anchor: .bottom)
            }
            .frame(height: compact ? 85 : 115)
            .offset(y: compact ? -10 : -14)
            
            // 漂浮翠綠靈氣光點
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color.green)
                    .frame(width: 4, height: 4)
                    .offset(
                        x: CGFloat(i * 18 - 36),
                        y: particlesActive ? CGFloat(-20 - i * 8) : 10
                    )
                    .opacity(particlesActive ? 0.8 : 0)
            }
        }
    }
    
    // MARK: 3. 水：大水沖刷
    private var waterSurgeView: some View {
        ZStack {
            // 背景深藍旋渦
            Circle()
                .fill(RadialGradient(colors: [Color.blue.opacity(0.3), .clear], center: .center, startRadius: 10, endRadius: 70))
                .scaleEffect(pulse ? 1.15 : 0.95)
            
            // 奔湧的浪濤曲線 (Layer 1)
            Path { p in
                let w: CGFloat = compact ? 140 : 200
                let h: CGFloat = compact ? 120 : 160
                p.move(to: CGPoint(x: 0, y: h * 0.7))
                p.addCurve(
                    to: CGPoint(x: w, y: h * 0.45),
                    control1: CGPoint(x: w * 0.3, y: h * 0.2),
                    control2: CGPoint(x: w * 0.7, y: h * 0.9)
                )
                p.addLine(to: CGPoint(x: w, y: h))
                p.addLine(to: CGPoint(x: 0, y: h))
                p.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.45, blue: 0.85).opacity(0.7), Color(red: 0.2, green: 0.7, blue: 0.95).opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: animPhase > 0.2 ? 0 : -50)
            
            // 滔天巨浪浪尖 (Layer 2)
            Path { p in
                let w: CGFloat = compact ? 140 : 200
                let h: CGFloat = compact ? 120 : 160
                p.move(to: CGPoint(x: 0, y: h * 0.8))
                p.addCurve(
                    to: CGPoint(x: w, y: h * 0.35),
                    control1: CGPoint(x: w * 0.4, y: h * 0.1),
                    control2: CGPoint(x: w * 0.6, y: h * 0.7)
                )
                p.addLine(to: CGPoint(x: w, y: h))
                p.addLine(to: CGPoint(x: 0, y: h))
                p.closeSubpath()
            }
            .stroke(Color.white.opacity(0.9), lineWidth: compact ? 3 : 4)
            .offset(x: animPhase > 0.1 ? 0 : -40)
            
            // 水花飛濺水珠
            ForEach(0..<7, id: \.self) { i in
                Image(systemName: "drop.fill")
                    .font(.system(size: CGFloat(i % 3 * 3 + 8)))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                    .offset(
                        x: particlesActive ? CGFloat(sin(Double(i)) * (compact ? 45 : 65)) : -20,
                        y: particlesActive ? CGFloat(-cos(Double(i)) * (compact ? 30 : 45) - 10) : 20
                    )
                    .opacity(particlesActive ? 0.9 : 0)
            }
        }
    }
    
    // MARK: 4. 火：火焰噴發
    private var fireEruptionView: some View {
        ZStack {
            // 炙熱紅光背景
            Circle()
                .fill(RadialGradient(colors: [Color.red.opacity(0.35), Color.orange.opacity(0.15), .clear], center: .center, startRadius: 5, endRadius: 70))
                .scaleEffect(pulse ? 1.2 : 0.9)
            
            // 外層赤烈火焰
            Image(systemName: "flame.fill")
                .font(.system(size: compact ? 68 : 95))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.red, Color(red: 0.95, green: 0.3, blue: 0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(animPhase > 0.1 ? (pulse ? 1.08 : 0.96) : 0.2, anchor: .bottom)
                .offset(y: compact ? -10 : -14)
                .shadow(color: .red, radius: 8)
            
            // 核心金黃烈焰
            Image(systemName: "flame.fill")
                .font(.system(size: compact ? 44 : 62))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(animPhase > 0.2 ? (pulse ? 1.12 : 0.92) : 0.2, anchor: .bottom)
                .offset(y: compact ? -5 : -8)
                .shadow(color: .yellow, radius: 5)
            
            // 升騰火星
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(i % 2 == 0 ? Color.yellow : Color.orange)
                    .frame(width: CGFloat(i % 3 + 3), height: CGFloat(i % 3 + 3))
                    .offset(
                        x: CGFloat((i - 4) * (compact ? 12 : 16)),
                        y: particlesActive ? CGFloat(-45 - i * 6) : 10
                    )
                    .opacity(particlesActive ? 0.85 : 0)
            }
        }
    }
    
    // MARK: 5. 土：泥土堆疊
    private var earthStackView: some View {
        ZStack {
            // 巍峨土黃光暈
            Circle()
                .fill(RadialGradient(colors: [Color(red: 0.75, green: 0.55, blue: 0.3).opacity(0.3), .clear], center: .center, startRadius: 5, endRadius: 65))
                .scaleEffect(pulse ? 1.1 : 0.95)
            
            VStack(spacing: compact ? 2 : 4) {
                Spacer()
                
                // 頂層山石 (第 3 層堆疊)
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: compact ? 28 : 38))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.9, green: 0.75, blue: 0.55), Color(red: 0.7, green: 0.5, blue: 0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: animPhase > 0.6 ? 0 : -35)
                    .opacity(animPhase > 0.6 ? 1.0 : 0.0)
                    .shadow(radius: 3)
                
                // 中層岩板 (第 2 層堆疊)
                HStack(spacing: compact ? 4 : 6) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(colors: [Color(red: 0.65, green: 0.45, blue: 0.25), Color(red: 0.5, green: 0.32, blue: 0.18)], startPoint: .top, endPoint: .bottom))
                        .frame(width: compact ? 45 : 62, height: compact ? 14 : 18)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(colors: [Color(red: 0.72, green: 0.52, blue: 0.3), Color(red: 0.55, green: 0.38, blue: 0.2)], startPoint: .top, endPoint: .bottom))
                        .frame(width: compact ? 38 : 52, height: compact ? 14 : 18)
                }
                .offset(y: animPhase > 0.3 ? 0 : -25)
                .opacity(animPhase > 0.3 ? 1.0 : 0.0)
                
                // 底層磐石厚土 (第 1 層基石)
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.55, green: 0.38, blue: 0.2), Color(red: 0.4, green: 0.26, blue: 0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: compact ? 100 : 140, height: compact ? 18 : 24)
                    .scaleEffect(x: animPhase > 0.1 ? 1.0 : 0.2, anchor: .center)
            }
            .frame(height: compact ? 90 : 120)
            .offset(y: compact ? -12 : -16)
            
            // 堆疊撞擊塵土碎石特效
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.75, green: 0.55, blue: 0.35))
                    .frame(width: CGFloat(i % 3 + 3), height: CGFloat(i % 3 + 3))
                    .offset(
                        x: particlesActive ? CGFloat((i - 3) * (compact ? 20 : 28)) : 0,
                        y: particlesActive ? CGFloat(compact ? 24 : 32) : 0
                    )
                    .opacity(particlesActive ? 0.8 : 0)
            }
        }
    }
}

// MARK: - 五行相生相剋互動動態特效 (結算時展演)

struct ElementInteractionClashView: View {
    let interaction: PairwiseInteraction
    
    @State private var animStep: CGFloat = 0
    @State private var impactFlash: Bool = false
    @State private var floatingEffect: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 標題與類型標籤
            HStack(spacing: 6) {
                Image(systemName: interaction.effect == .heal ? "sparkles" : "bolt.fill")
                    .font(.caption)
                    .foregroundColor(interaction.effect == .heal ? .green : .red)
                
                Text(interaction.interactionTitle)
                    .font(.elementChinese(size: 14))
                    .fontWeight(.heavy)
                    .foregroundColor(interaction.effect == .heal ? .green : .red)
                
                Spacer()
                
                Text(interaction.effect == .heal ? "【相生】生命 +1" : "【相剋】生命 -1")
                    .font(.elementChinese(size: 11))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(interaction.effect == .heal ? Color.green : Color.red)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            
            // 動態碰撞核心場景
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                (interaction.effect == .heal ? Color.green : Color.red).opacity(0.35),
                                lineWidth: 1.5
                            )
                    )
                
                // 背景生剋能量流動波紋
                if interaction.effect == .heal {
                    // 相生：柔和旋轉光環
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [interaction.sourceElement.primaryColor, interaction.targetElement.primaryColor, .green, .clear],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(floatingEffect ? 360 : 0))
                } else {
                    // 相剋：強烈衝擊波
                    Circle()
                        .stroke(Color.red.opacity(impactFlash ? 0.7 : 0), lineWidth: 4)
                        .scaleEffect(impactFlash ? 1.4 : 0.8)
                }
                
                HStack(spacing: 24) {
                    // 攻擊/施生方 (Source)
                    VStack(spacing: 4) {
                        Text(interaction.sourceName)
                            .font(.elementChinese(size: 11))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Circle()
                                .fill(interaction.sourceElement.primaryColor)
                                .frame(width: 46, height: 46)
                                .shadow(color: interaction.sourceElement.primaryColor.opacity(0.5), radius: 4)
                            
                            VStack(spacing: 1) {
                                Image(systemName: interaction.sourceElement.iconName)
                                    .font(.system(size: 13, weight: .bold))
                                Text(interaction.sourceElement.rawValue)
                                    .font(.elementChinese(size: 14))
                            }
                            .foregroundColor(.white)
                        }
                        
                        Text(interaction.sourceElement.attackName)
                            .font(.elementChinese(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .offset(x: animStep > 0.2 ? 10 : -15)
                    
                    // 中間交互作用動態標誌
                    VStack(spacing: 4) {
                        Image(systemName: interaction.effect == .heal ? "arrow.right.circle.fill" : "burst.fill")
                            .font(.system(size: 26))
                            .foregroundColor(interaction.effect == .heal ? .green : .red)
                            .scaleEffect(impactFlash ? 1.3 : 1.0)
                        
                        Text(interaction.effect == .heal ? "滋養" : "重創")
                            .font(.elementChinese(size: 11))
                            .foregroundColor(interaction.effect == .heal ? .green : .red)
                    }
                    
                    // 受作用方 (Target)
                    VStack(spacing: 4) {
                        Text(interaction.targetName)
                            .font(.elementChinese(size: 11))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Circle()
                                .fill(interaction.targetElement.primaryColor)
                                .frame(width: 46, height: 46)
                                .shadow(color: interaction.targetElement.primaryColor.opacity(0.5), radius: 4)
                            
                            VStack(spacing: 1) {
                                Image(systemName: interaction.targetElement.iconName)
                                    .font(.system(size: 13, weight: .bold))
                                Text(interaction.targetElement.rawValue)
                                    .font(.elementChinese(size: 14))
                            }
                            .foregroundColor(.white)
                            
                            // 結算飄字提示 (+1 / -1)
                            Text(interaction.effect == .heal ? "+1" : "-1")
                                .font(.elemental(size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(interaction.effect == .heal ? Color.green : Color.red)
                                .clipShape(Capsule())
                                .shadow(radius: 3)
                                .offset(x: 20, y: floatingEffect ? -26 : -18)
                                .scaleEffect(impactFlash ? 1.15 : 1.0)
                        }
                        
                        Text(interaction.targetElement.attackName)
                            .font(.elementChinese(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .offset(x: animStep > 0.2 ? -5 : 15)
                }
            }
            .padding(.horizontal, 8)
            
            // 視覺意境解說
            Text(interaction.visualNarration)
                .font(.elementChinese(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.06))
        )
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animStep = 1.0
            }
            withAnimation(.easeInOut(duration: 0.4).repeatCount(3, autoreverses: true)) {
                impactFlash = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                floatingEffect = true
            }
        }
    }
}

// MARK: - 勢均力敵 (同拳無生剋) 碰撞特效

struct TieClashView: View {
    let element: FiveElement
    
    @State private var ringPulse = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(.blue)
                Text("同氣相求 · 勢均力敵")
                    .font(.elementChinese(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(height: 95)
                
                Circle()
                    .stroke(element.primaryColor.opacity(0.5), lineWidth: 2)
                    .frame(width: 75, height: 75)
                    .scaleEffect(ringPulse ? 1.3 : 0.8)
                    .opacity(ringPulse ? 0.2 : 0.8)
                
                HStack(spacing: 20) {
                    ZStack {
                        Circle().fill(element.primaryColor).frame(width: 40, height: 40)
                        Text(element.rawValue).font(.elementChinese(size: 16)).fontWeight(.bold).foregroundColor(.white)
                    }
                    
                    Text("⚔️")
                        .font(.title2)
                        .scaleEffect(ringPulse ? 1.2 : 0.9)
                    
                    ZStack {
                        Circle().fill(element.primaryColor).frame(width: 40, height: 40)
                        Text(element.rawValue).font(.elementChinese(size: 16)).fontWeight(.bold).foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 8)
            
            Text("雙方皆出【\(element.rawValue)】，氣機相抵，未分高下，無生剋發生！")
                .font(.elementChinese(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.06)))
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                ringPulse = true
            }
        }
    }
}
