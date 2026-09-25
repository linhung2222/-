//
//  Views.swift
//  五行拳
//
//  共用 UI 元件視圖模組
//  定義生命值勾玉量表、五行元素選拳圓鈕、揭曉卡片以及五行太極生剋圖鑑視圖
//

import SwiftUI

// MARK: - 生命值勾玉顯示槽 (0 ~ 10 點)

/// 玩家生命值量表元件
/// 以古代武俠勾玉珠串概念視覺化呈現血量，支援不同上限（2~10 點）之動態縮放與瀕死警戒色彩
struct HealthBarView: View {
    /// 當前剩餘生命值
    let currentHealth: Int
    /// 生命值上限（預設為 5，最高可支援 10 點）
    var maxHealth: Int = 5
    /// 玩家名稱
    let playerName: String
    /// 是否為電腦 AI
    let isAI: Bool
    /// 是否已出局陣亡
    let isEliminated: Bool
    /// 是否採用精簡緊湊排版（適用於雙人同屏或多玩家對戰版面）
    var compact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 頂部列：角色身分圖示、玩家姓名與數值狀態
            HStack(spacing: 6) {
                // 角色圖示：AI 採用晶片圖示 (cpu)，人類玩家採用人物圖示 (person.fill)
                Image(systemName: isAI ? "cpu" : "person.fill")
                    .font(.system(size: compact ? 11 : 13))
                    .foregroundColor(isEliminated ? .secondary : (isAI ? .purple : .blue))
                
                // 玩家名稱文字
                Text(playerName)
                    .font(.elementChinese(size: compact ? 12 : 14))
                    .foregroundColor(isEliminated ? .secondary : .primary)
                    .lineLimit(1)
                
                Spacer()
                
                // 狀態徽記：出局標籤或目前生命值分數比
                if isEliminated {
                    Text("已出局")
                        .font(.elementChinese(size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.18))
                        .foregroundColor(.red)
                        .clipShape(Capsule())
                } else {
                    Text("(\(currentHealth)/\(maxHealth))")
                        .font(.elemental(size: compact ? 12 : 14))
                        .foregroundColor(healthColor)
                }
            }
            
            // 下方：生命勾玉珠陣列
            // 依據血量上限自動調整珠子大小與間距，避免版面溢出
            let circleSize: CGFloat = compact ? (maxHealth > 7 ? 11 : (maxHealth > 5 ? 13 : 17)) : (maxHealth > 7 ? 14 : (maxHealth > 5 ? 16 : 20))
            let innerSize: CGFloat = compact ? (maxHealth > 7 ? 7 : (maxHealth > 5 ? 9 : 12)) : (maxHealth > 7 ? 10 : (maxHealth > 5 ? 12 : 15))
            let dotSpacing: CGFloat = compact ? (maxHealth > 7 ? 2.5 : (maxHealth > 5 ? 3.5 : 5)) : (maxHealth > 7 ? 3.5 : (maxHealth > 5 ? 5 : 7))
            
            HStack(spacing: dotSpacing) {
                ForEach(1...maxHealth, id: \.self) { index in
                    ZStack {
                        // 外框環
                        Circle()
                            .stroke(Color.secondary.opacity(0.25), lineWidth: 1.5)
                            .frame(width: circleSize, height: circleSize)
                        
                        // 內層實心亮珠（若該點數仍存活）
                        if !isEliminated && index <= currentHealth {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: currentHealth >= maxHealth ? [Color.yellow, Color.orange] : (currentHealth == 1 ? [Color.red, Color.orange] : [Color.green, Color.teal]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: innerSize, height: innerSize)
                                .shadow(color: healthColor.opacity(0.5), radius: 2)
                        } else {
                            // 扣損的空心暗珠
                            Circle()
                                .fill(Color.gray.opacity(0.12))
                                .frame(width: innerSize, height: innerSize)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isEliminated ? Color.secondary.opacity(0.06) : Color.secondary.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isEliminated ? Color.red.opacity(0.2) : Color.clear, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .opacity(isEliminated ? 0.65 : 1.0)
    }
    
    /// 生命值警示色彩：滿血金黃、瀕危赤紅、健康翠綠
    private var healthColor: Color {
        if currentHealth >= maxHealth {
            return .yellow
        } else if currentHealth <= 1 {
            return .red
        } else {
            return .green
        }
    }
}

// MARK: - 五行單個按鈕／圓形選擇鍵

/// 五行出拳圓形按鈕元件
/// 呈現五行專屬色彩、微光陰影與立體外環，支援選中時的彈簧放大回饋
struct ElementButton: View {
    /// 代表的五行元素
    let element: FiveElement
    /// 是否正被當前玩家選中
    let isSelected: Bool
    /// 按鈕直徑大小（點數，points）
    let size: CGFloat
    /// 點擊觸發之動作閉包
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // 主體色彩漸層圓球
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [element.secondaryColor, element.primaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                        .shadow(
                            color: isSelected ? element.primaryColor.opacity(0.8) : Color.black.opacity(0.15),
                            radius: isSelected ? 8 : 3,
                            x: 0,
                            y: isSelected ? 3 : 2
                        )
                    
                    // 外邊框光圈（選中時呈現純白加粗光環）
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.35), lineWidth: isSelected ? 3 : 1.5)
                        .frame(width: size, height: size)
                    
                    // 中央元素圖示與漢字
                    VStack(spacing: 2) {
                        Image(systemName: element.iconName)
                            .font(.system(size: size * 0.32, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                        
                        Text(element.rawValue)
                            .font(.elementChinese(size: size * 0.28))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2)
                    }
                }
                .scaleEffect(isSelected ? 1.06 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - 五行卡片（顯示出拳揭曉與狀態）

/// 擂台各玩家的拳招展示卡片元件
/// 支援暗牌遮罩（輪流下注防止偷看）、揭曉牌面、陣亡骷髏印記以及結算浮動飄字 (+1 / -1)
struct ElementCardView: View {
    /// 該玩家出拳之五行（若未出則為 nil）
    let element: FiveElement?
    /// 卡片頂部玩家標題文字
    let title: String
    /// 是否處於暗牌遮蔽狀態（未開牌時隱藏出拳內容）
    let isHidden: Bool
    /// 該玩家是否已淘汰出局
    var isEliminated: Bool = false
    /// 結算時的血量增減數值（例如 +1 或 -1）
    var hpChange: Int? = nil
    /// 卡片寬度
    var width: CGFloat = 85
    /// 卡片高度
    var height: CGFloat = 115
    
    var body: some View {
        VStack(spacing: 6) {
            // 卡片頂部名稱標籤
            HStack(spacing: 4) {
                Text(title)
                    .font(.elementChinese(size: 12))
                    .foregroundColor(isEliminated ? .secondary : .primary)
                    .lineLimit(1)
            }
            
            // 卡片主體
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .frame(width: width, height: height)
                    .foregroundStyle(cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(cardBorderColor, lineWidth: 2)
                    )
                    .shadow(color: cardShadowColor, radius: 6, x: 0, y: 3)
                
                if isEliminated {
                    // 陣亡出局覆蓋標記
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.seal.fill")
                            .font(.system(size: width * 0.35))
                            .foregroundColor(.red.opacity(0.8))
                        Text("已出局")
                            .font(.elementChinese(size: width * 0.16))
                            .foregroundColor(.red)
                    }
                } else if isHidden {
                    // 暗牌背面狀態（已下注但尚未亮牌）
                    VStack(spacing: 6) {
                        Image(systemName: element != nil ? "checkmark.circle.fill" : "questionmark.circle.fill")
                            .font(.system(size: width * 0.34))
                            .foregroundColor(element != nil ? .blue : .secondary.opacity(0.6))
                        Text(element != nil ? "已出拳" : "待出拳")
                            .font(.elementChinese(size: width * 0.16))
                            .foregroundColor(.secondary)
                    }
                } else if let el = element {
                    // 揭曉開牌面：展示該五行招式大字與神獸圖標
                    VStack(spacing: 6) {
                        Image(systemName: el.iconName)
                            .font(.system(size: width * 0.36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 3)
                        
                        Text(el.rawValue)
                            .font(.elementChinese(size: width * 0.28))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 3)
                    }
                } else {
                    // 尚未出拳等待狀態
                    Text("待出拳")
                        .font(.elementChinese(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // 血量增減浮動氣泡（結算亮牌後展示）
                if !isHidden, let change = hpChange, !isEliminated {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(change > 0 ? "+\(change)" : (change < 0 ? "\(change)" : "0"))
                                .font(.elemental(size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(change > 0 ? Color.green : (change < 0 ? Color.red : Color.gray))
                                .clipShape(Capsule())
                                .padding(4)
                        }
                    }
                    .frame(width: width, height: height)
                }
            }
        }
    }
    
    /// 卡片背景填色樣式
    private var cardBackground: some ShapeStyle {
        if isEliminated {
            return AnyShapeStyle(Color.secondary.opacity(0.05))
        } else if isHidden || element == nil {
            return AnyShapeStyle(Color.secondary.opacity(0.08))
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [element!.secondaryColor, element!.primaryColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    /// 卡片外框線顏色
    private var cardBorderColor: Color {
        if isEliminated {
            return Color.red.opacity(0.3)
        } else if let el = element, !isHidden {
            return el.primaryColor
        }
        return Color.secondary.opacity(0.25)
    }
    
    /// 卡片投影光暈色彩
    private var cardShadowColor: Color {
        if let el = element, !isHidden, !isEliminated {
            return el.primaryColor.opacity(0.4)
        }
        return Color.black.opacity(0.08)
    }
}

// MARK: - 五行相生相剋太極圖解視圖

/// 五行生剋圖鑑視圖（太極循環解說）
/// 以五芒星幾何排列表現五行環繞排列：外圈順時鐘代表「相生」，內向交叉五角星代表「相剋」
struct WuXingDiagramView: View {
    var body: some View {
        VStack(spacing: 16) {
            // 圖鑑標題
            Text("五行生剋圖鑑")
                .font(.elementChinese(size: 20))
                .fontWeight(.bold)
            
            // 中央太極五芒星排盤
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    .frame(width: 220, height: 220)
                
                // 生與剋的幾何同心圓五等分佈局（木、火、土、金、水）
                let elements: [FiveElement] = [.wood, .fire, .earth, .metal, .water]
                ForEach(0..<5) { i in
                    let angle = Angle.degrees(Double(i) * 72.0 - 90.0)
                    let radius: CGFloat = 85
                    let x = cos(angle.radians) * radius
                    let y = sin(angle.radians) * radius
                    
                    let el = elements[i]
                    ZStack {
                        Circle()
                            .fill(el.primaryColor)
                            .frame(width: 44, height: 44)
                            .shadow(color: el.primaryColor.opacity(0.4), radius: 4)
                        
                        Text(el.rawValue)
                            .font(.elementChinese(size: 20))
                            .foregroundColor(.white)
                    }
                    .offset(x: x, y: y)
                }
                
                // 核心口訣說明氣泡
                VStack(spacing: 2) {
                    Text("生：外圈順生")
                        .font(.elementChinese(size: 11))
                        .foregroundColor(.green)
                    Text("剋：內星相剋")
                        .font(.elementChinese(size: 11))
                        .foregroundColor(.red)
                }
                .padding(6)
                .background(.regularMaterial)
                .cornerRadius(8)
            }
            .frame(width: 240, height: 240)
            
            // 下方詳細五行哲理與生命增減說明看板
            VStack(alignment: .leading, spacing: 10) {
                // 相生區塊
                HStack(alignment: .top) {
                    Label("相生（被生者生命值 +1）", systemImage: "sparkles")
                        .font(.elementChinese(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                Text("金生水 → 水生木 → 木生火 → 火生土 → 土生金")
                    .font(.elementChinese(size: 12))
                    .foregroundColor(.secondary)
                
                Divider()
                
                // 相剋區塊
                HStack(alignment: .top) {
                    Label("相剋（被剋者生命值 -1）", systemImage: "bolt.fill")
                        .font(.elementChinese(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                Text("金剋木 → 木剋土 → 土剋水 → 水剋火 → 火剋金")
                    .font(.elementChinese(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.12))
            .cornerRadius(12)
        }
        .padding()
    }
}
