//
//  FullScreenClashViews.swift
//  五行拳
//
//  全螢幕電影級五行相生相剋動態對決視圖模組
//  以沈浸式全螢幕視覺呈現五行拳理之相生相剋哲學：
//    【五大相剋】
//      1. 金剋木（劈拳破崩拳）：金色神兵破空橫斬參天巨樹，木屑碎葉四散
//      2. 木剋土（崩拳破橫拳）：青木神根深扎大地，撕裂厚土堅岩破土而出
//      3. 土剋水（橫拳破鑽拳）：崇山巍峨天降岩壁，萬鈞厚土截斷奔湧狂浪
//      4. 水剋火（鑽拳破炮拳）：九天銀河狂濤奔湧，巨浪傾盆澆熄沖天烈焰並騰起白霧
//      5. 火剋金（炮拳破劈拳）：熊熊火海烈焰熾烤，銷鑠神兵鋼刃熔成金液滴落
//    【五大相生】
//      6. 金生水（劈拳生鑽拳）：寶刀金氣凝聚天地靈液，凝露化為澎湃瀑布蔚藍清泉
//      7. 水生木（鑽拳生崩拳）：靈泉化作及時甘霖，滋養青木神樹破土暴長花開繁盛
//      8. 木生火（崩拳生炮拳）：靈木良柴投入火海，薪火相傳烈焰轟鳴金星漫天
//      9. 火生土（炮拳生橫拳）：熾熱神火焚化萬物，岩漿冷卻凝結成深厚沃土與玄武岩山
//      10. 土生金（橫拳生劈拳）：厚土大地裂開靈脈，百鍊神鋒吸納地脈金精破土拔出
//    【勢均力敵】
//      11. 同拳相撞：雙方同拳氣機相抵，產生強烈光環衝擊波各退數步
//

import SwiftUI

// MARK: - 全螢幕相生相剋結算動態對決視圖 (Full-Screen Interaction Theater)

/// 電影級全螢幕生剋結算劇院視圖
/// 提供上方對陣雙方名片與生剋標籤、中央大比例動態演繹舞台、下方詩意戰況解說與分組切換控制項
struct FullScreenClashView: View {
    /// 該回合所有兩兩交互作用清單
    let interactions: [PairwiseInteraction]
    /// 該回合玩家動作清單（用於平手時判斷相同元素）
    let actions: [PlayerRoundAction]
    /// 當前正在展示的生剋事件索引（Binding）
    @Binding var activeIndex: Int
    /// 劇院視圖是否顯示（Binding）
    @Binding var isPresented: Bool
    /// 下一回合開始之回呼閉包（可選）
    var onNextRound: (() -> Void)? = nil
    
    /// 劇院切換時的全螢幕閃白效果旗標
    @State private var screenFlash: Bool = false
    /// 強制刷新中央舞臺動態的 UUID
    @State private var stageKey: UUID = UUID()
    
    /// 當前聚焦展示的單一生剋事件
    var currentInteraction: PairwiseInteraction? {
        guard !interactions.isEmpty, interactions.indices.contains(activeIndex) else { return nil }
        return interactions[activeIndex]
    }
    
    /// 若無生剋事件（雙方出同拳平局），取得雙方相同的五行元素
    var tieElement: FiveElement? {
        if interactions.isEmpty, let first = actions.first?.choice {
            return first
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            // 全螢幕深色玄幻背景與雙方元素流光光暈
            backgroundAtmosphere
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // 頂部看板：關閉按鈕與戰鬥雙方名牌
                headerFightersBar
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                
                Spacer(minLength: 4)
                
                // 中央全螢幕大比例動態特效舞台
                centralClashStage
                    .id(stageKey)
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                
                Spacer(minLength: 4)
                
                // 底部結算戰況解說與操作按鈕面板
                bottomControlPanel
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            
            // 震撼全螢幕閃光白屏轉場
            if screenFlash {
                Color.white
                    .ignoresSafeArea()
                    .opacity(0.4)
                    .transition(.opacity)
            }
        }
        .onAppear {
            triggerStageAnimation()
        }
        .onChange(of: activeIndex) { _, _ in
            triggerStageAnimation()
        }
    }
    
    /// 觸發舞臺重新播放動畫與閃白轉場
    private func triggerStageAnimation() {
        stageKey = UUID()
        withAnimation(.easeOut(duration: 0.2)) {
            screenFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.easeOut(duration: 0.3)) {
                screenFlash = false
            }
        }
    }
    
    // MARK: - 背景玄幻靈氣氛圍
    
    /// 依據對決雙方五行主色混合渲染的流光光暈
    private var backgroundAtmosphere: some View {
        let color1: Color = currentInteraction?.sourceElement.primaryColor ?? tieElement?.primaryColor ?? .purple
        let color2: Color = currentInteraction?.targetElement.primaryColor ?? tieElement?.secondaryColor ?? .blue
        
        return ZStack {
            Color.black
            
            RadialGradient(
                colors: [color1.opacity(0.35), color2.opacity(0.2), Color.black],
                center: .topLeading,
                startRadius: 50,
                endRadius: 500
            )
            
            RadialGradient(
                colors: [color2.opacity(0.35), color1.opacity(0.15), Color.black],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 500
            )
        }
    }
    
    // MARK: - 頂部對戰雙方資訊列
    
    /// 頂部對陣名片：施展方、生剋徽記、受作用方與關閉劇院叉號
    private var headerFightersBar: some View {
        HStack(alignment: .center) {
            if let item = currentInteraction {
                // 施展方（Source）
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(item.sourceElement.primaryColor)
                            .frame(width: 44, height: 44)
                            .shadow(color: item.sourceElement.primaryColor.opacity(0.8), radius: 6)
                        Text(item.sourceElement.rawValue)
                            .font(.elementChinese(size: 20))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.sourceName)
                            .font(.elementChinese(size: 15))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Text(item.sourceElement.attackName)
                            .font(.elementChinese(size: 11))
                            .foregroundColor(item.sourceElement.secondaryColor)
                    }
                }
                
                Spacer()
                
                // 生剋徽記
                VStack(spacing: 2) {
                    Text(item.effect == .heal ? "相生" : "相剋")
                        .font(.elementChinese(size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(item.effect == .heal ? Color.green : Color.red)
                        .clipShape(Capsule())
                        .shadow(color: (item.effect == .heal ? Color.green : Color.red).opacity(0.8), radius: 8)
                    
                    Image(systemName: item.effect == .heal ? "arrow.right.circle.fill" : "bolt.fill")
                        .font(.caption)
                        .foregroundColor(item.effect == .heal ? .green : .red)
                }
                
                Spacer()
                
                // 受作用方（Target）
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(item.targetName)
                            .font(.elementChinese(size: 15))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Text(item.targetElement.attackName)
                            .font(.elementChinese(size: 11))
                            .foregroundColor(item.targetElement.secondaryColor)
                    }
                    ZStack {
                        Circle()
                            .fill(item.targetElement.primaryColor)
                            .frame(width: 44, height: 44)
                            .shadow(color: item.targetElement.primaryColor.opacity(0.8), radius: 6)
                        Text(item.targetElement.rawValue)
                            .font(.elementChinese(size: 20))
                            .foregroundColor(.white)
                    }
                }
            } else if let el = tieElement {
                // 平手狀態
                Text("雙方皆出【\(el.rawValue)】")
                    .font(.elementChinese(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text("勢均力敵")
                    .font(.elementChinese(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
            
            // 跳過／關閉按鈕
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
        )
    }
    
    // MARK: - 中央核心全螢幕動態互動特效舞臺
    
    /// 依據相生或相剋對決組合，自動分流派發至 11 種專屬電影級動畫舞臺
    @ViewBuilder
    private var centralClashStage: some View {
        if let item = currentInteraction {
            switch (item.sourceElement, item.targetElement) {
            // 五類相生
            case (.metal, .water):
                MetalGeneratesWaterCinematicView()
            case (.water, .wood):
                WaterGeneratesWoodCinematicView()
            case (.wood, .fire):
                WoodGeneratesFireCinematicView()
            case (.fire, .earth):
                FireGeneratesEarthCinematicView()
            case (.earth, .metal):
                EarthGeneratesMetalCinematicView()
                
            // 五類相剋
            case (.metal, .wood):
                MetalOvercomesWoodCinematicView()
            case (.wood, .earth):
                WoodOvercomesEarthCinematicView()
            case (.earth, .water):
                EarthOvercomesWaterCinematicView()
            case (.water, .fire):
                WaterOvercomesFireCinematicView()
            case (.fire, .metal):
                FireOvercomesMetalCinematicView()
                
            default:
                TieCinematicView(element: item.sourceElement)
            }
        } else if let el = tieElement {
            TieCinematicView(element: el)
        }
    }
    
    // MARK: - 底部結算控制面板
    
    /// 底部戰況敘事與換幕按鈕列
    private var bottomControlPanel: some View {
        VStack(spacing: 10) {
            if let item = currentInteraction {
                // 生剋稱號與數值增減標籤
                HStack(spacing: 8) {
                    Text(item.interactionTitle)
                        .font(.elementChinese(size: 18))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: item.effect == .heal ? "heart.fill" : "drop.fill")
                        Text(item.effect == .heal ? "生命 +1" : "生命 -1")
                            .font(.elemental(size: 13))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(item.effect == .heal ? Color.green : Color.red)
                    .clipShape(Capsule())
                    .shadow(color: (item.effect == .heal ? Color.green : Color.red).opacity(0.8), radius: 6)
                }
                
                // 動畫視覺詩意解說
                Text(item.visualNarration)
                    .font(.elementChinese(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("全體氣機凝練相同，雙拳碰撞勢均力敵，各自化解，無傷而退！")
                    .font(.elementChinese(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // 控制操作按鈕列
            HStack(spacing: 12) {
                // 若有多組對決，提供「觀看下一組」按鈕
                if interactions.count > 1 {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            activeIndex = (activeIndex + 1) % interactions.count
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("下一組生剋對決")
                                .font(.elementChinese(size: 13))
                            Text("(\(activeIndex + 1)/\(interactions.count))")
                                .font(.elemental(size: 11))
                            Image(systemName: "arrow.right.circle")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.secondary.opacity(0.4))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                
                // 返回棋盤按鈕
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text("返回棋盤")
                            .font(.elementChinese(size: 13))
                        Image(systemName: "square.grid.2x2")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.35))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // 若有下一回合 callback，提供直接進入下一回合按鈕
                if let nextRoundAction = onNextRound {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                            nextRoundAction()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("下一回合")
                                .font(.elementChinese(size: 13))
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(color: .purple.opacity(0.5), radius: 5)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.65))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
    }
}

// MARK: ================= 全螢幕相剋動態動畫 (5 類) =================

// MARK: 1. 金剋木：利刃破空，大刀橫斬參天巨樹，木屑斷枝漫天飛濺

/// 金剋木（劈拳破崩拳）電影級全螢幕動畫
/// 金色大刀迅猛揮落，伴隨璀璨斬痕，巨樹應聲斷裂兩半，漫天飛舞翠綠落葉與木屑
struct MetalOvercomesWoodCinematicView: View {
    @State private var bladeSwing: CGFloat = -80
    @State private var slashTriggered: Bool = false
    @State private var treeSplit: CGFloat = 0
    @State private var woodSplinters: Bool = false
    
    var body: some View {
        ZStack {
            // 右側巨樹
            HStack(spacing: treeSplit * 25) {
                // 樹幹左半部（被砍斷向左傾斜）
                VStack(spacing: 0) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 45))
                        .foregroundColor(.green)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [Color(red: 0.4, green: 0.25, blue: 0.1), Color(red: 0.25, green: 0.15, blue: 0.05)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 24, height: 110)
                }
                .rotationEffect(.degrees(-treeSplit * 18))
                
                // 樹幹右半部（被砍斷向右傾斜）
                VStack(spacing: 0) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 55))
                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.35))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [Color(red: 0.45, green: 0.28, blue: 0.12), Color(red: 0.3, green: 0.18, blue: 0.08)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 24, height: 110)
                }
                .rotationEffect(.degrees(treeSplit * 22))
            }
            .offset(x: 40, y: 30)
            
            // 橫斬金光斬痕 (Slash Line)
            if slashTriggered {
                Path { p in
                    p.move(to: CGPoint(x: 20, y: 90))
                    p.addLine(to: CGPoint(x: 320, y: 260))
                }
                .stroke(
                    LinearGradient(colors: [.white, .yellow, Color(red: 1, green: 0.6, blue: 0.1), .clear], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .shadow(color: .yellow, radius: 12)
                .transition(.opacity)
            }
            
            // 左上方金色大刀（大刀一揮斬落）
            VStack(spacing: 0) {
                // 刀尖與鋒刃
                ZStack {
                    Path { p in
                        p.move(to: CGPoint(x: 18, y: 0))
                        p.addLine(to: CGPoint(x: 36, y: 130))
                        p.addLine(to: CGPoint(x: 0, y: 130))
                        p.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [.white, Color(red: 1.0, green: 0.88, blue: 0.4), Color(red: 0.85, green: 0.65, blue: 0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 4, height: 110)
                        .offset(x: 7, y: 10)
                }
                .frame(width: 36, height: 130)
                
                // 刀護手
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 55, height: 12)
                
                // 刀柄
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.brown)
                    .frame(width: 12, height: 40)
            }
            .shadow(color: .yellow.opacity(0.8), radius: 12)
            .rotationEffect(.degrees(bladeSwing))
            .offset(x: bladeSwing > 0 ? 50 : -110, y: bladeSwing > 0 ? 20 : -90)
            
            // 爆散木屑與落葉
            if woodSplinters {
                ForEach(0..<14, id: \.self) { i in
                    Image(systemName: i % 2 == 0 ? "leaf.fill" : "sparkle")
                        .font(.system(size: CGFloat(i % 3 * 6 + 12)))
                        .foregroundColor(i % 2 == 0 ? .green : .yellow)
                        .offset(
                            x: CGFloat(cos(Double(i) * 0.45) * 110) + 40,
                            y: CGFloat(sin(Double(i) * 0.45) * 85) + 30
                        )
                        .opacity(0.85)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.45)) {
                bladeSwing = 40
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeOut(duration: 0.15)) {
                    slashTriggered = true
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    treeSplit = 1.0
                    woodSplinters = true
                }
            }
        }
    }
}

// MARK: 2. 木剋土：青木盤根如神龍破土，崩碎厚土堅岩

/// 木剋土（崩拳破橫拳）電影級全螢幕動畫
/// 青木神根自地底破出，蜿蜒如龍向上竄生，堅固岩層巨山崩裂四散
struct WoodOvercomesEarthCinematicView: View {
    @State private var rootsGrowth: CGFloat = 0
    @State private var rockCracked: Bool = false
    @State private var dustBoom: Bool = false
    
    var body: some View {
        ZStack {
            // 中央巍峨厚土岩山
            VStack(spacing: 4) {
                Spacer()
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.8, green: 0.6, blue: 0.4), Color(red: 0.55, green: 0.38, blue: 0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(x: rockCracked ? 15 : 0, y: rockCracked ? 8 : 0)
                    .rotationEffect(.degrees(rockCracked ? 10 : 0))
                
                HStack(spacing: rockCracked ? 30 : 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.6, green: 0.42, blue: 0.22))
                        .frame(width: 90, height: 35)
                        .rotationEffect(.degrees(rockCracked ? -12 : 0))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.5, green: 0.35, blue: 0.18))
                        .frame(width: 90, height: 35)
                        .rotationEffect(.degrees(rockCracked ? 15 : 0))
                }
            }
            .frame(height: 220)
            
            // 穿透破出的青木神根 (Roots drilling through earth)
            ForEach(0..<5, id: \.self) { i in
                Path { p in
                    p.move(to: CGPoint(x: 150 + (i - 2) * 45, y: 320))
                    p.addQuadCurve(
                        to: CGPoint(x: 130 + (i - 2) * 55, y: 140 - (i % 2) * 35),
                        control: CGPoint(x: 180 + (i - 2) * 30, y: 220)
                    )
                }
                .trim(from: 0, to: rootsGrowth)
                .stroke(
                    LinearGradient(colors: [Color(red: 0.2, green: 0.75, blue: 0.35), Color(red: 0.45, green: 0.9, blue: 0.4)], startPoint: .bottom, endPoint: .top),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .shadow(color: .green, radius: 8)
            }
            
            // 碎石煙塵爆散
            if dustBoom {
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(Color(red: 0.75, green: 0.55, blue: 0.35))
                        .frame(width: CGFloat(i % 3 * 5 + 6), height: CGFloat(i % 3 * 5 + 6))
                        .offset(
                            x: CGFloat(cos(Double(i) * 0.55) * 120),
                            y: CGFloat(sin(Double(i) * 0.55) * 75) + 60
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                rootsGrowth = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    rockCracked = true
                    dustBoom = true
                }
            }
        }
    }
}

// MARK: 3. 土剋水：崇山築堤，巨石如天降神壁轟然墜落，徹底截斷奔湧大水

/// 土剋水（橫拳破鑽拳）電影級全螢幕動畫
/// 萬鈞崇山巨石由九天轟然墜落，激發震波強行阻斷並壓制澎湃水浪
struct EarthOvercomesWaterCinematicView: View {
    @State private var mountainDrop: CGFloat = -260
    @State private var waterDam: Bool = false
    @State private var shockwave: Bool = false
    
    var body: some View {
        ZStack {
            // 下方洶湧大水 (奔騰水浪)
            VStack {
                Spacer()
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        WaveShape(phase: CGFloat(i) * 0.5)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.15, green: 0.55, blue: 0.95).opacity(0.8), Color(red: 0.05, green: 0.35, blue: 0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: waterDam ? 45 : 95)
                            .offset(y: waterDam ? 25 : 0)
                    }
                }
            }
            .frame(height: 180)
            
            // 從天而降的萬鈞崇山巨岩壁
            VStack(spacing: 0) {
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 85))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.65, blue: 0.45), Color(red: 0.6, green: 0.4, blue: 0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 10)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [Color(red: 0.65, green: 0.45, blue: 0.25), Color(red: 0.4, green: 0.25, blue: 0.12)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 220, height: 60)
            }
            .offset(y: mountainDrop)
            
            // 墜地衝擊波
            if shockwave {
                Circle()
                    .stroke(Color.orange.opacity(0.8), lineWidth: 6)
                    .frame(width: 260, height: 260)
                    .scaleEffect(1.2)
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.45)) {
                mountainDrop = 50
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
                withAnimation(.easeOut(duration: 0.25)) {
                    shockwave = true
                    waterDam = true
                }
            }
        }
    }
}

// MARK: 4. 水剋火：狂濤傾盆澆滅烈火，升騰滾滾白霧蒸氣

/// 水剋火（鑽拳破炮拳）電影級全螢幕動畫
/// 巨型浪濤自左側奔湧撲蓋右方熊熊大火，火勢瞬間熄滅並爆發大量蒸氣白霧
struct WaterOvercomesFireCinematicView: View {
    @State private var waveSurge: CGFloat = -260
    @State private var fireExtinguished: Bool = false
    @State private var steamPuff: Bool = false
    
    var body: some View {
        ZStack {
            // 右側原本熊熊烈火
            VStack {
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.system(size: fireExtinguished ? 24 : 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: fireExtinguished ? [.gray, .secondary] : [.yellow, .orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(fireExtinguished ? 0.3 : 1.0, anchor: .bottom)
                    .shadow(color: fireExtinguished ? .clear : .red, radius: 15)
            }
            .frame(height: 220)
            .offset(x: 50, y: 20)
            
            // 左側奔湧撲滅的滔天狂濤巨浪
            Path { p in
                p.move(to: CGPoint(x: -80, y: 60))
                p.addCurve(
                    to: CGPoint(x: 280, y: 240),
                    control1: CGPoint(x: 60, y: 40),
                    control2: CGPoint(x: 180, y: 120)
                )
                p.addLine(to: CGPoint(x: 280, y: 350))
                p.addLine(to: CGPoint(x: -80, y: 350))
                p.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.65, blue: 1.0).opacity(0.9), Color(red: 0.05, green: 0.35, blue: 0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .offset(x: waveSurge)
            
            // 熄滅時升騰的滾滾白霧蒸氣
            if steamPuff {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.65))
                        .frame(width: CGFloat(i % 3 * 16 + 28), height: CGFloat(i % 3 * 16 + 28))
                        .offset(
                            x: CGFloat((i - 4) * 20) + 50,
                            y: CGFloat(-i * 18)
                        )
                        .blur(radius: 6)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                waveSurge = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    fireExtinguished = true
                    steamPuff = true
                }
            }
        }
    }
}

// MARK: 5. 火剋金：烈焰火海銷鑠金刀，大刀燒至赤紅軟化熔化滴落

/// 火剋金（炮拳破劈拳）電影級全螢幕動畫
/// 烈焰包圍金色神兵，高溫熾烤下刀身泛起赤紅高熱並軟化熔融，鐵水滴落消散
struct FireOvercomesMetalCinematicView: View {
    @State private var fireEngulf: Bool = false
    @State private var metalMelt: Bool = false
    @State private var moltenDrops: Bool = false
    
    var body: some View {
        ZStack {
            // 背景烈火包圍火海
            ZStack {
                ForEach(0..<6, id: \.self) { i in
                    Image(systemName: "flame.fill")
                        .font(.system(size: CGFloat(i % 2 * 30 + 70)))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                        )
                        .offset(x: CGFloat(cos(Double(i)) * (fireEngulf ? 85 : 140)), y: CGFloat(sin(Double(i)) * 40))
                        .scaleEffect(fireEngulf ? 1.2 : 0.6)
                        .shadow(color: .orange, radius: 10)
                }
            }
            
            // 中央大刀（被高溫烈火燒至赤紅消融）
            VStack(spacing: 0) {
                Path { p in
                    p.move(to: CGPoint(x: 18, y: 0))
                    p.addLine(to: CGPoint(x: 36, y: 130))
                    p.addLine(to: CGPoint(x: 0, y: 130))
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: metalMelt ? [Color.red, Color.orange, Color.yellow] : [Color.white, Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 36, height: 130)
                .scaleEffect(y: metalMelt ? 0.75 : 1.0, anchor: .bottom)
                .rotationEffect(.degrees(metalMelt ? 12 : 0))
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.5, green: 0.2, blue: 0.1))
                    .frame(width: 50, height: 10)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.brown)
                    .frame(width: 12, height: 35)
            }
            .shadow(color: metalMelt ? .red : .yellow, radius: metalMelt ? 15 : 6)
            
            // 熔化的金屬鐵水滴落
            if moltenDrops {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                        .offset(x: CGFloat(i * 8 - 20), y: CGFloat(40 + i * 14))
                        .shadow(color: .yellow, radius: 4)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                fireEngulf = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    metalMelt = true
                    moltenDrops = true
                }
            }
        }
    }
}

// MARK: ================= 全螢幕相生動態動畫 (5 類) =================

// MARK: 6. 金生水：靈刃化泉，金刀靈光震顫凝出源源不絕的蔚藍清泉

/// 金生水（劈拳生鑽拳）電影級全螢幕動畫
/// 金刀高懸泛起純金光華，刀尖凝露化珠滴落，於下方匯聚為奔騰蔚藍清泉瀑布
struct MetalGeneratesWaterCinematicView: View {
    @State private var bladeGlow: Bool = false
    @State private var waterFlow: CGFloat = 0
    @State private var dewDrops: Bool = false
    
    var body: some View {
        ZStack {
            // 上方懸浮綻放金光的寶刀
            VStack(spacing: 0) {
                Path { p in
                    p.move(to: CGPoint(x: 16, y: 0))
                    p.addLine(to: CGPoint(x: 32, y: 110))
                    p.addLine(to: CGPoint(x: 0, y: 110))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [.white, Color(red: 1, green: 0.9, blue: 0.4), .yellow], startPoint: .top, endPoint: .bottom))
                .frame(width: 32, height: 110)
                
                RoundedRectangle(cornerRadius: 3).fill(Color.orange).frame(width: 44, height: 8)
                RoundedRectangle(cornerRadius: 2).fill(Color.brown).frame(width: 10, height: 30)
            }
            .shadow(color: .yellow, radius: bladeGlow ? 18 : 6)
            .offset(y: -70)
            .scaleEffect(bladeGlow ? 1.08 : 0.95)
            
            // 刀尖凝聚滴落的甘露水珠
            if dewDrops {
                ForEach(0..<7, id: \.self) { i in
                    Image(systemName: "drop.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.4, green: 0.85, blue: 1.0))
                        .offset(x: CGFloat(sin(Double(i)) * 18), y: CGFloat(-15 + i * 22))
                        .shadow(color: .blue, radius: 4)
                }
            }
            
            // 下方由金氣化出的蔚藍澎湃清泉瀑布
            VStack {
                Spacer()
                WaveShape(phase: waterFlow)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.3, green: 0.8, blue: 1.0), Color(red: 0.05, green: 0.45, blue: 0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 110)
                    .shadow(color: .blue.opacity(0.8), radius: 10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                bladeGlow = true
            }
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                waterFlow = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.4)) {
                    dewDrops = true
                }
            }
        }
    }
}

// MARK: 7. 水生木：天降靈泉甘霖，靈樹瞬間拔地而起、枝繁葉茂生生不息

/// 水生木（鑽拳生崩拳）電影級全螢幕動畫
/// 上方雲層傾降甘霖雨露，下方靈木吸飽水汽暴風生長，枝頭綻放璀璨繁花
struct WaterGeneratesWoodCinematicView: View {
    @State private var rainFall: Bool = false
    @State private var treeBloom: CGFloat = 0.2
    @State private var flowersPop: Bool = false
    
    var body: some View {
        ZStack {
            // 上方雲層與落下甘霖
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "cloud.rain.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 0.4, green: 0.75, blue: 1.0))
                }
                Spacer()
            }
            .padding(.top, 10)
            
            // 傾盆甘霖雨點
            if rainFall {
                ForEach(0..<14, id: \.self) { i in
                    Image(systemName: "drop.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 1.0))
                        .offset(
                            x: CGFloat((i - 7) * 22),
                            y: CGFloat(i % 3 * 35 - 30)
                        )
                }
            }
            
            // 下方吸飽甘霖後拔地暴長的參天靈樹
            VStack(spacing: 0) {
                Spacer()
                
                // 茂密樹冠
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.3, green: 0.9, blue: 0.45), Color(red: 0.12, green: 0.65, blue: 0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 110, height: 95)
                        .shadow(color: .green, radius: 10)
                    
                    // 盛開的花朵靈芝
                    if flowersPop {
                        ForEach(0..<6, id: \.self) { i in
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                                .offset(x: CGFloat(cos(Double(i)) * 40), y: CGFloat(sin(Double(i)) * 32))
                        }
                    }
                }
                
                // 樹幹
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(colors: [Color(red: 0.45, green: 0.28, blue: 0.15), Color(red: 0.3, green: 0.18, blue: 0.08)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 26, height: 110)
            }
            .frame(height: 230)
            .scaleEffect(treeBloom, anchor: .bottom)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.35)) {
                rainFall = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                    treeBloom = 1.0
                    flowersPop = true
                }
            }
        }
    }
}

// MARK: 8. 木生火：青木靈枝投薪入火，神火轟鳴騰空，烈焰倍盛

/// 木生火（崩拳生炮拳）電影級全螢幕動畫
/// 左右靈木投薪入爐，中心烈焰獲得燃料後暴漲轟鳴，騰躍璀璨金紅大火與漫天星火
struct WoodGeneratesFireCinematicView: View {
    @State private var woodFeed: Bool = false
    @State private var fireSurge: CGFloat = 0.3
    @State private var embersExplode: Bool = false
    
    var body: some View {
        ZStack {
            // 兩側投入的靈木薪柴
            HStack(spacing: woodFeed ? 20 : 160) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .rotationEffect(.degrees(45))
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.3, green: 0.85, blue: 0.4))
                    .rotationEffect(.degrees(-45))
            }
            .offset(y: 30)
            
            // 中央騰空而起的璀璨金紅大火
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 130))
                        .foregroundStyle(LinearGradient(colors: [.red, .orange, .yellow], startPoint: .top, endPoint: .bottom))
                        .shadow(color: .red, radius: 20)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(LinearGradient(colors: [.white, .yellow], startPoint: .top, endPoint: .bottom))
                }
            }
            .frame(height: 240)
            .scaleEffect(fireSurge, anchor: .bottom)
            
            // 漫天升騰的熾熱金星
            if embersExplode {
                ForEach(0..<16, id: \.self) { i in
                    Circle()
                        .fill(i % 2 == 0 ? Color.yellow : Color.orange)
                        .frame(width: CGFloat(i % 3 * 3 + 4), height: CGFloat(i % 3 * 3 + 4))
                        .offset(x: CGFloat((i - 8) * 16), y: CGFloat(-70 - i * 6))
                        .shadow(color: .yellow, radius: 4)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                woodFeed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                    fireSurge = 1.0
                    embersExplode = true
                }
            }
        }
    }
}

// MARK: 9. 火生土：神火焚化虛妄，熔岩冷卻凝結成深厚沃土與玄武岩山

/// 火生土（炮拳生橫拳）電影級全螢幕動畫
/// 上方神火焚化四方化為暖紅光霞，餘燼降落下方冷卻凝成巍峨厚重大地與山岩
struct FireGeneratesEarthCinematicView: View {
    @State private var fireCalm: Bool = false
    @State private var earthSolidify: CGFloat = 0.1
    @State private var geoGlow: Bool = false
    
    var body: some View {
        ZStack {
            // 上方漫天烈火化作溫潤暖紅光霞
            Circle()
                .fill(RadialGradient(colors: [Color.orange.opacity(fireCalm ? 0.2 : 0.6), .clear], center: .center, startRadius: 10, endRadius: 160))
                .scaleEffect(fireCalm ? 1.2 : 0.7)
            
            // 下方熔岩冷卻凝固成堅實大地岩層
            VStack(spacing: 6) {
                Spacer()
                
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 75))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.9, green: 0.75, blue: 0.55), Color(red: 0.65, green: 0.45, blue: 0.25)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .orange.opacity(geoGlow ? 0.8 : 0.2), radius: 10)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 0.2), Color(red: 0.35, green: 0.22, blue: 0.1)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 220, height: 45)
            }
            .frame(height: 230)
            .scaleEffect(earthSolidify, anchor: .bottom)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                fireCalm = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    earthSolidify = 1.0
                    geoGlow = true
                }
            }
        }
    }
}

// MARK: 10. 土生金：厚土裂開地脈靈脈，金光沖天，百鍊神鋒金刀破土拔出

/// 土生金（橫拳生劈拳）電影級全螢幕動畫
/// 厚實岩層向兩側裂開，沖天金芒中百鍊神刀出鞘破土拔出，金石閃耀
struct EarthGeneratesMetalCinematicView: View {
    @State private var earthPart: CGFloat = 0
    @State private var bladeRise: CGFloat = 80
    @State private var goldenRays: Bool = false
    
    var body: some View {
        ZStack {
            // 金光靈脈射線光圈
            if goldenRays {
                Circle()
                    .stroke(Color.yellow.opacity(0.8), lineWidth: 4)
                    .frame(width: 240, height: 240)
                    .scaleEffect(1.2)
            }
            
            // 地底升起的百鍊神鋒金刀
            VStack(spacing: 0) {
                Path { p in
                    p.move(to: CGPoint(x: 18, y: 0))
                    p.addLine(to: CGPoint(x: 36, y: 130))
                    p.addLine(to: CGPoint(x: 0, y: 130))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors: [.white, Color(red: 1, green: 0.9, blue: 0.4), .yellow], startPoint: .top, endPoint: .bottom))
                .frame(width: 36, height: 130)
                
                RoundedRectangle(cornerRadius: 4).fill(Color.orange).frame(width: 50, height: 10)
                RoundedRectangle(cornerRadius: 3).fill(Color.brown).frame(width: 12, height: 35)
            }
            .shadow(color: .yellow, radius: 15)
            .offset(y: bladeRise)
            
            // 下方裂開的大地岩板 (Earth Parting)
            VStack {
                Spacer()
                HStack(spacing: earthPart * 40) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.6, green: 0.4, blue: 0.2))
                        .frame(width: 110, height: 60)
                        .rotationEffect(.degrees(-earthPart * 8))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.5, green: 0.35, blue: 0.18))
                        .frame(width: 110, height: 60)
                        .rotationEffect(.degrees(earthPart * 8))
                }
            }
            .frame(height: 160)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.45)) {
                earthPart = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    bladeRise = -30
                    goldenRays = true
                }
            }
        }
    }
}

// MARK: 11. 勢均力敵 (同拳對撼) 全螢幕衝擊波

/// 同拳平手電影級全螢幕動畫
/// 雙方出相同拳法高速對撞，迸發強烈同色衝擊波反彈震盪
struct TieCinematicView: View {
    /// 雙方共同出拳之五行屬性
    let element: FiveElement
    
    @State private var clashOffset: CGFloat = 130
    @State private var shockwaveBurst: Bool = false
    
    var body: some View {
        ZStack {
            // 中央衝擊波光圈
            if shockwaveBurst {
                Circle()
                    .stroke(element.primaryColor, lineWidth: 6)
                    .frame(width: 250, height: 250)
                    .scaleEffect(1.2)
                    .transition(.opacity)
            }
            
            // 雙方拳勁對撞
            HStack(spacing: clashOffset * 2) {
                ZStack {
                    Circle()
                        .fill(element.primaryColor)
                        .frame(width: 70, height: 70)
                        .shadow(color: element.primaryColor, radius: 12)
                    Text(element.rawValue)
                        .font(.elementChinese(size: 32))
                        .foregroundColor(.white)
                }
                
                ZStack {
                    Circle()
                        .fill(element.primaryColor)
                        .frame(width: 70, height: 70)
                        .shadow(color: element.primaryColor, radius: 12)
                    Text(element.rawValue)
                        .font(.elementChinese(size: 32))
                        .foregroundColor(.white)
                }
            }
            
            Text("💥")
                .font(.system(size: shockwaveBurst ? 55 : 20))
                .scaleEffect(shockwaveBurst ? 1.2 : 0.3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                clashOffset = 20
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                withAnimation(.easeOut(duration: 0.25)) {
                    shockwaveBurst = true
                    clashOffset = 45
                }
            }
        }
    }
}

// MARK: - 波浪形狀輔助路徑

/// 正弦波水流 Shape，用於動態模擬水流奔湧與瀑布起伏
struct WaveShape: Shape {
    /// 正弦波相位偏移（驅動連續滾動）
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.5
        let wavelength = width * 0.7
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 5) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase * 2 * .pi)
            let y = midHeight + sine * (height * 0.35)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        return path
    }
}
