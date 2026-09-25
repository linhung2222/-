//
//  Views.swift
//  五行拳
//

import SwiftUI

// MARK: - 生命值顯示槽 (0 ~ 10)
struct HealthBarView: View {
    let currentHealth: Int
    var maxHealth: Int = 5
    let playerName: String
    let isAI: Bool
    let isEliminated: Bool
    var compact: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                // 角色圖示
                Image(systemName: isAI ? "cpu" : "person.fill")
                    .font(.system(size: compact ? 11 : 13))
                    .foregroundColor(isEliminated ? .secondary : (isAI ? .purple : .blue))
                
                Text(playerName)
                    .font(.elementChinese(size: compact ? 12 : 14))
                    .foregroundColor(isEliminated ? .secondary : .primary)
                    .lineLimit(1)
                
                Spacer()
                
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
            
            // 生命勾玉槽
            let circleSize: CGFloat = compact ? (maxHealth > 7 ? 11 : (maxHealth > 5 ? 13 : 17)) : (maxHealth > 7 ? 14 : (maxHealth > 5 ? 16 : 20))
            let innerSize: CGFloat = compact ? (maxHealth > 7 ? 7 : (maxHealth > 5 ? 9 : 12)) : (maxHealth > 7 ? 10 : (maxHealth > 5 ? 12 : 15))
            let dotSpacing: CGFloat = compact ? (maxHealth > 7 ? 2.5 : (maxHealth > 5 ? 3.5 : 5)) : (maxHealth > 7 ? 3.5 : (maxHealth > 5 ? 5 : 7))
            
            HStack(spacing: dotSpacing) {
                ForEach(1...maxHealth, id: \.self) { index in
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.25), lineWidth: 1.5)
                            .frame(width: circleSize, height: circleSize)
                        
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

// MARK: - 五行單個按鈕/卡片
struct ElementButton: View {
    let element: FiveElement
    let isSelected: Bool
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
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
                    
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.35), lineWidth: isSelected ? 3 : 1.5)
                        .frame(width: size, height: size)
                    
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
struct ElementCardView: View {
    let element: FiveElement?
    let title: String
    let isHidden: Bool
    var isEliminated: Bool = false
    var hpChange: Int? = nil
    var width: CGFloat = 85
    var height: CGFloat = 115
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.elementChinese(size: 12))
                    .foregroundColor(isEliminated ? .secondary : .primary)
                    .lineLimit(1)
            }
            
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
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.seal.fill")
                            .font(.system(size: width * 0.35))
                            .foregroundColor(.red.opacity(0.8))
                        Text("已出局")
                            .font(.elementChinese(size: width * 0.16))
                            .foregroundColor(.red)
                    }
                } else if isHidden {
                    // 暗牌背面
                    VStack(spacing: 6) {
                        Image(systemName: element != nil ? "checkmark.circle.fill" : "questionmark.circle.fill")
                            .font(.system(size: width * 0.34))
                            .foregroundColor(element != nil ? .blue : .secondary.opacity(0.6))
                        Text(element != nil ? "已出拳" : "待出拳")
                            .font(.elementChinese(size: width * 0.16))
                            .foregroundColor(.secondary)
                    }
                } else if let el = element {
                    // 揭曉牌面
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
                    // 未出拳
                    Text("待出拳")
                        .font(.elementChinese(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // 血量增減浮標 (結算時顯示)
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
    
    private var cardBorderColor: Color {
        if isEliminated {
            return Color.red.opacity(0.3)
        } else if let el = element, !isHidden {
            return el.primaryColor
        }
        return Color.secondary.opacity(0.25)
    }
    
    private var cardShadowColor: Color {
        if let el = element, !isHidden, !isEliminated {
            return el.primaryColor.opacity(0.4)
        }
        return Color.black.opacity(0.08)
    }
}

// MARK: - 五行相生相剋太極圖解視圖
struct WuXingDiagramView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("五行生剋圖鑑")
                .font(.elementChinese(size: 20))
                .fontWeight(.bold)
            
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    .frame(width: 220, height: 220)
                
                // 生與剋的幾何佈局
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
            
            VStack(alignment: .leading, spacing: 10) {
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
