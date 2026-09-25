//
//  GameCoverView.swift
//  五行拳
//
//  Created on 2026/9/25.
//

import SwiftUI

// MARK: - 遊戲封面視圖 (Game Cover / Splash Screen)
struct GameCoverView: View {
    /// 點擊進入遊戲的回調
    var onStartGame: () -> Void
    
    // 動態狀態
    @State private var appearAnimation = false
    @State private var rotationAngle: Double = 0
    @State private var elementPulse = false
    @State private var showPrompt = false
    @State private var promptBlink = false
    @State private var isDismissing = false
    @State private var auraScale: CGFloat = 0.95
    
    // 五行相生次序：金 -> 水 -> 木 -> 火 -> 土
    private let generatingOrder: [FiveElement] = [.metal, .water, .wood, .fire, .earth]
    
    // 背景浮動微粒的隨機分佈
    private let backgroundStars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = (0..<28).map { i in
        let seed = Double(i)
        let x = CGFloat((sin(seed * 91.0) + 1.0) / 2.0)
        let y = CGFloat((cos(seed * 73.0) + 1.0) / 2.0)
        let size = CGFloat(1.8 + (sin(seed * 17.0) + 1.0) * 2.2)
        let opacity = 0.2 + (cos(seed * 31.0) + 1.0) * 0.4
        return (x, y, size, opacity)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. 深色玄幻武道背景
                coverBackground
                
                // 2. 漂浮五行靈韻光點
                floatingParticles(size: geometry.size)
                
                // 3. 主要內容區域：AppIcon 與 特殊造型遊戲名稱
                VStack(spacing: 0) {
                    Spacer(minLength: 24)
                    
                    // 中央：五行意象環繞的 AppIcon
                    appIconSection
                        .scaleEffect(appearAnimation ? 1.0 : 0.72)
                        .opacity(appearAnimation ? 1.0 : 0.0)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // 遊戲名稱：特殊造型字體與五行意象融合
                    gameTitleSection
                        .scaleEffect(appearAnimation ? 1.0 : 0.85)
                        .opacity(appearAnimation ? 1.0 : 0.0)
                    
                    Spacer()
                        .frame(height: 18)
                    
                    // 五行拳法意象飾條（金木水火土五拳融合）
                    fiveElementsBadgeBar
                        .opacity(appearAnimation ? 0.9 : 0.0)
                    
                    Spacer(minLength: 20)
                    
                    // 4. 中間偏下區域：兩秒後緩慢閃爍的「點擊進入遊戲」小白字
                    promptSection
                        .frame(height: 54)
                    
                    Spacer(minLength: 36)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            // 點擊判定：等到小白字顯示後，玩家點擊任意位置即可淡出進入遊戲
            .onTapGesture {
                handleUserTap()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startEntryAnimations()
        }
    }
    
    // MARK: - 1. 背景漸變
    private var coverBackground: some View {
        ZStack {
            // 深邃夜空黑
            Color(red: 0.03, green: 0.04, blue: 0.08)
                .ignoresSafeArea()
            
            // 五行相融中心流光光暈
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.72, blue: 0.35).opacity(0.18), // 金光
                    Color(red: 0.90, green: 0.28, blue: 0.22).opacity(0.12), // 火炎
                    Color(red: 0.18, green: 0.55, blue: 0.88).opacity(0.14), // 水韻
                    Color(red: 0.22, green: 0.68, blue: 0.38).opacity(0.08), // 木華
                    Color.clear
                ]),
                center: .center,
                startRadius: 30,
                endRadius: 380
            )
            .scaleEffect(auraScale)
            .ignoresSafeArea()
            
            // 頂底漸變遮罩，營造舞台聚焦感
            LinearGradient(
                colors: [
                    Color.black.opacity(0.65),
                    Color.clear,
                    Color.black.opacity(0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - 2. 漂浮光點微粒
    private func floatingParticles(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            for star in backgroundStars {
                let rect = CGRect(
                    x: star.x * canvasSize.width,
                    y: star.y * canvasSize.height,
                    width: star.size,
                    height: star.size
                )
                let starPath = Circle().path(in: rect)
                context.fill(starPath, with: .color(Color.white.opacity(star.opacity)))
            }
        }
        .allowsHitTesting(false)
        .opacity(appearAnimation ? 0.85 : 0.0)
    }
    
    // MARK: - 3. AppIcon 與 五行元素圍繞環
    private var appIconSection: some View {
        ZStack {
            // 五行光環 (旋轉生剋動態光帶)
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            FiveElement.metal.primaryColor,
                            FiveElement.water.primaryColor,
                            FiveElement.wood.primaryColor,
                            FiveElement.fire.primaryColor,
                            FiveElement.earth.primaryColor,
                            FiveElement.metal.primaryColor
                        ],
                        center: .center
                    ),
                    lineWidth: 3.5
                )
                .frame(width: 184, height: 184)
                .rotationEffect(.degrees(rotationAngle))
                .blur(radius: 1.2)
                .opacity(0.85)
            
            // 外圈呼吸光暈
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.yellow.opacity(0.18), Color.clear],
                        center: .center,
                        startRadius: 60,
                        endRadius: 115
                    )
                )
                .frame(width: 230, height: 230)
                .scaleEffect(elementPulse ? 1.06 : 0.95)
            
            // 核心 AppIcon 圖像容器
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.black.opacity(0.65))
                    .frame(width: 136, height: 136)
                    .shadow(color: Color.black.opacity(0.7), radius: 18, x: 0, y: 8)
                
                // 專屬 AppIcon 圖片資產
                Image("GameAppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            }
            
            // 五行意象節點環繞 (依相生次序：金 -> 水 -> 木 -> 火 -> 土)
            ForEach(Array(generatingOrder.enumerated()), id: \.element.id) { index, element in
                elementOrbitNode(element: element, index: index, total: generatingOrder.count)
            }
        }
        .frame(width: 250, height: 250)
    }
    
    /// 五行節點佈局於圓周
    private func elementOrbitNode(element: FiveElement, index: Int, total: Int) -> some View {
        let angleStep = (2 * Double.pi) / Double(total)
        // 起始角度設在頂端 (-pi/2) 並順時針排列
        let currentAngle = angleStep * Double(index) - (Double.pi / 2)
        let radius: CGFloat = 104
        
        let x = CGFloat(cos(currentAngle)) * radius
        let y = CGFloat(sin(currentAngle)) * radius
        
        return ZStack {
            // 節點外層發光環
            Circle()
                .fill(element.primaryColor.opacity(0.32))
                .frame(width: 36, height: 36)
                .scaleEffect(elementPulse ? 1.15 : 0.92)
            
            // 節點主體
            Circle()
                .fill(
                    LinearGradient(
                        colors: [element.primaryColor, element.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
                )
                .shadow(color: element.primaryColor.opacity(0.85), radius: 6)
            
            // 元素字樣
            Text(element.rawValue)
                .font(.elementChinese(size: 14))
                .foregroundColor(.white)
        }
        .offset(x: x, y: y)
    }
    
    // MARK: - 4. 遊戲名稱（特殊造型字體與元素意象圍繞及融合）
    private var gameTitleSection: some View {
        VStack(spacing: 8) {
            // 古風五行修飾導引
            HStack(spacing: 8) {
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, Color(red: 0.85, green: 0.72, blue: 0.35)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 38, height: 1.5)
                
                Text("形意拳法 · 五行相生相剋")
                    .font(.elementChinese(size: 13))
                    .foregroundColor(Color(red: 0.95, green: 0.85, blue: 0.65))
                    .tracking(3)
                
                Rectangle()
                    .fill(LinearGradient(colors: [Color(red: 0.85, green: 0.72, blue: 0.35), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 38, height: 1.5)
            }
            
            // 主標題「五 行 拳」：特殊造型字體，融合金木水火土五彩光華與元素雕琢
            HStack(spacing: 12) {
                // 「五」：金土相融之剛毅
                stylizedCharacterView(
                    char: "五",
                    gradient: [
                        FiveElement.metal.primaryColor,
                        FiveElement.earth.primaryColor
                    ]
                )
                
                // 「行」：水木滋榮之靈動
                stylizedCharacterView(
                    char: "行",
                    gradient: [
                        FiveElement.water.primaryColor,
                        FiveElement.wood.primaryColor
                    ]
                )
                
                // 「拳」：烈火精金之勁力
                stylizedCharacterView(
                    char: "拳",
                    gradient: [
                        FiveElement.fire.primaryColor,
                        Color(red: 1.0, green: 0.45, blue: 0.2),
                        FiveElement.metal.secondaryColor
                    ]
                )
            }
            .padding(.vertical, 4)
            
            // 英文輔助標題與宗師朱砂印
            HStack(spacing: 10) {
                Text("FIVE ELEMENTS MARTIAL ARTS")
                    .font(.elemental(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                    .tracking(2.5)
                
                // 朱砂印章
                Text("宗師")
                    .font(.elementChinese(size: 9))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.82, green: 0.18, blue: 0.18))
                    .cornerRadius(3)
                    .shadow(color: Color.red.opacity(0.4), radius: 2)
            }
        }
    }
    
    /// 特殊造型單字組件：立體層次、外光暈與金屬高光雕琢
    private func stylizedCharacterView(char: String, gradient: [Color]) -> some View {
        ZStack {
            // 背後深墨陰影
            Text(char)
                .font(.elementChinese(size: 54))
                .foregroundColor(.black.opacity(0.85))
                .offset(x: 2, y: 3)
                .blur(radius: 2)
            
            // 外層五行光暈擴散
            Text(char)
                .font(.elementChinese(size: 54))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 8)
                .opacity(0.45)
            
            // 正式文字：特殊襯線雕琢字體 + 五行漸層
            Text(char)
                .font(.elementChinese(size: 54))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white] + gradient,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // 頂部高光描邊效果
                    Text(char)
                        .font(.elementChinese(size: 54))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                colors: [Color.white.opacity(0.85), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask(
                                Text(char)
                                    .font(.elementChinese(size: 54))
                            )
                        )
                )
        }
    }
    
    /// 五行招式意象標籤列（金·劈拳、木·崩拳、水·鑽拳、火·炮拳、土·橫拳）
    private var fiveElementsBadgeBar: some View {
        HStack(spacing: 8) {
            ForEach(generatingOrder) { el in
                HStack(spacing: 3) {
                    Image(systemName: el.iconName)
                        .font(.system(size: 9))
                    Text(el.attackName)
                        .font(.elementChinese(size: 11))
                }
                .foregroundColor(el.primaryColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(el.primaryColor.opacity(0.12))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(el.primaryColor.opacity(0.35), lineWidth: 0.8)
                )
            }
        }
    }
    
    // MARK: - 5. 中間偏下區域：兩秒後緩慢閃爍的「點擊進入遊戲」小白字
    private var promptSection: some View {
        VStack(spacing: 8) {
            if showPrompt {
                HStack(spacing: 8) {
                    Text("—")
                        .foregroundColor(.white.opacity(0.35))
                    
                    Text("點擊進入遊戲")
                        .font(.elementChinese(size: 16))
                        .foregroundColor(.white)
                        .tracking(3)
                    
                    Text("—")
                        .foregroundColor(.white.opacity(0.35))
                }
                .opacity(promptBlink ? 1.0 : 0.22)
                .scaleEffect(promptBlink ? 1.02 : 0.98)
                .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
    }
    
    // MARK: - 啟動各階段動畫
    private func startEntryAnimations() {
        // 1. 封面主視覺淡入與縮放
        withAnimation(.easeOut(duration: 1.0)) {
            appearAnimation = true
        }
        
        // 2. 元素環持續旋轉
        withAnimation(.linear(duration: 26.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // 3. 光暈呼吸節奏
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            elementPulse = true
            auraScale = 1.08
        }
        
        // 4. 嚴格符合需求：封面顯示 2 秒後，在中間偏下的地方出現緩慢閃爍小白字
        Task {
            try? await Task.sleep(for: .seconds(2.0))
            
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.6)) {
                    showPrompt = true
                }
                
                // 緩慢閃爍動畫 (1.3 秒循環一次平滑呼吸)
                withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                    promptBlink = true
                }
            }
        }
    }
    
    // MARK: - 處理玩家點擊
    private func handleUserTap() {
        // 必須等到小白字顯示後，點擊才觸發淡出進入遊戲
        guard showPrompt, !isDismissing else { return }
        isDismissing = true
        
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif
        
        onStartGame()
    }
}

#Preview {
    GameCoverView(onStartGame: {})
}
