//
//  FullScreenPunchViews.swift
//  五行拳
//
//  全螢幕五行拳招對決演出視圖模組
//  以高效能 SpriteKit 物理渲染引擎（60fps）驅動：
//    - 金（劈拳）：神兵利刃刀芒出鞘，火星流光隨行
//    - 木（崩拳）：神木如槍，翡翠螺旋氣勁與飛葉繽紛
//    - 水（鑽拳）：毒龍鑽水，深藍巨浪水龍捲渦流激盪
//    - 火（炮拳）：炮火連天，烈焰爆發與騰騰飛火
//    - 土（橫拳）：泰山壓頂，厚重土黃岩峰與奔騰碎石
//  並於碰撞時觸發白光衝擊波、粒子大爆發與鏡頭晃動打擊感
//

import SwiftUI
import SpriteKit

// MARK: - SpriteKit 出拳對決核心場景 (SpriteKit Punch Scene)

/// 負責渲染雙方蓄勢發勁、疾衝碰撞之 SpriteKit 核心場景
final class SpriteKitPunchScene: SKScene {
    
    // MARK: - 對決雙方屬性
    
    /// 左方選手姓名
    private let p1Name: String
    /// 左方選手出拳五行屬性
    private let p1Element: FiveElement
    /// 右方選手姓名
    private let p2Name: String
    /// 右方選手出拳五行屬性
    private let p2Element: FiveElement
    /// 雙方拳勁撞擊後完成之回呼閉包
    private let onClashComplete: (() -> Void)?
    
    // MARK: - 場景節點
    
    /// 包含場景所有動態物件之世界節點（便於統一施加震動鏡頭效果）
    private let worldNode = SKNode()
    /// 左方出拳實體節點
    private var p1PunchNode: SKNode?
    /// 右方出拳實體節點
    private var p2PunchNode: SKNode?
    /// 防止重複觸發碰撞衝擊的旗標
    private var hasImpacted = false
    
    /// 初始化 SpriteKit 出拳場景
    /// - Parameters:
    ///   - size: 場景畫布大小
    ///   - p1Name: 左方選手名稱
    ///   - p1Element: 左方出拳五行
    ///   - p2Name: 右方選手名稱
    ///   - p2Element: 右方出拳五行
    ///   - onClashComplete: 碰撞演出結束後之回呼
    init(
        size: CGSize,
        p1Name: String,
        p1Element: FiveElement,
        p2Name: String,
        p2Element: FiveElement,
        onClashComplete: (() -> Void)? = nil
    ) {
        self.p1Name = p1Name
        self.p1Element = p1Element
        self.p2Name = p2Name
        self.p2Element = p2Element
        self.onClashComplete = onClashComplete
        super.init(size: size)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5) // 將座標原點置於螢幕中心 (0, 0)
        self.scaleMode = .resizeFill
        self.backgroundColor = SKColor(red: 0.04, green: 0.05, blue: 0.08, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 當場景載入至 SKView 時觸發
    override func didMove(to view: SKView) {
        removeAllChildren()
        addChild(worldNode)
        setupBackground()
        setupPunches()
    }
    
    // MARK: - 1. 背景神秘氣脈星雲與太極法陣
    
    /// 建構背景旋轉之八卦五行星軌與漂浮靈氣微粒
    private func setupBackground() {
        let minDim = min(size.width, size.height)
        let ringRadius = max(70, minDim * 0.38)
        
        // 中心旋轉五行太極星陣光環
        let ring = SKShapeNode(circleOfRadius: ringRadius)
        ring.position = .zero
        ring.strokeColor = SKColor.white.withAlphaComponent(0.08)
        ring.lineWidth = 2
        ring.glowWidth = 4
        worldNode.addChild(ring)
        ring.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 16.0)))
        
        // 外層逆時針旋轉八卦星軌光環
        let outerRing = SKShapeNode(circleOfRadius: ringRadius * 1.25)
        outerRing.position = .zero
        outerRing.strokeColor = SKColor.white.withAlphaComponent(0.04)
        outerRing.lineWidth = 1.5
        worldNode.addChild(outerRing)
        outerRing.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi, duration: 24.0)))
        
        // 背景微光浮游靈氣粒子發射器
        let bgDust = SKEmitterNode()
        bgDust.particleTexture = SKTextureGenerator.glowCircle(size: 24)
        bgDust.particleBirthRate = 18
        bgDust.particleLifetime = 3.5
        bgDust.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        bgDust.position = .zero
        bgDust.particleSpeed = 20
        bgDust.particleSpeedRange = 15
        bgDust.emissionAngleRange = .pi * 2
        bgDust.particleColor = SKColor.white.withAlphaComponent(0.35)
        bgDust.particleScale = 0.25
        bgDust.particleScaleRange = 0.15
        bgDust.particleAlpha = 0.4
        bgDust.particleAlphaSpeed = -0.1
        bgDust.particleBlendMode = .add
        worldNode.addChild(bgDust)
    }
    
    // MARK: - 2. 構建並發射兩位玩家的五行拳術
    
    /// 配置雙方出拳發勁的三段式時間軸（蓄力吸氣 -> 疾衝突擊 -> 震撼交鋒）
    private func setupPunches() {
        let span = max(110, min(size.width * 0.36, 170))
        let p1StartX: CGFloat = -span
        let p2StartX: CGFloat = span
        let clashX1: CGFloat = -42
        let clashX2: CGFloat = 42
        
        // 構建 P1 出拳實體（由左向右發勁）
        let p1Node = makePunchNode(for: p1Element, isFacingRight: true)
        p1Node.position = CGPoint(x: p1StartX, y: 0)
        worldNode.addChild(p1Node)
        self.p1PunchNode = p1Node
        
        // 構建 P2 出拳實體（由右向左發勁）
        let p2Node = makePunchNode(for: p2Element, isFacingRight: false)
        p2Node.position = CGPoint(x: p2StartX, y: 0)
        worldNode.addChild(p2Node)
        self.p2PunchNode = p2Node
        
        // 階段 1：蓄力吸氣階段 (0.0s ~ 0.5s)：放大凝聚並微幅後撤蓄勢
        let p1Charge = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.45),
            SKAction.moveBy(x: -12, y: 0, duration: 0.1)
        ])
        let p2Charge = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.45),
            SKAction.moveBy(x: 12, y: 0, duration: 0.1)
        ])
        
        p1Node.run(p1Charge)
        p2Node.run(p2Charge)
        
        // 階段 2：出拳發勁疾衝階段 (0.55s ~ 1.35s)：雷霆突擊衝向中央
        let strikeDuration: TimeInterval = 0.8
        let strike1 = SKAction.moveTo(x: clashX1, duration: strikeDuration)
        strike1.timingMode = .easeIn
        let p1Strike = SKAction.sequence([
            SKAction.wait(forDuration: 0.55),
            strike1
        ])
        
        let strike2 = SKAction.moveTo(x: clashX2, duration: strikeDuration)
        strike2.timingMode = .easeIn
        let p2Strike = SKAction.sequence([
            SKAction.wait(forDuration: 0.55),
            strike2
        ])
        
        p1Node.run(p1Strike)
        p2Node.run(p2Strike)
        
        // 階段 3：碰撞交會時刻 (1.35s)
        let totalTimeToClash = 0.55 + strikeDuration
        let waitAndClash = SKAction.sequence([
            SKAction.wait(forDuration: totalTimeToClash),
            SKAction.run { [weak self] in
                self?.triggerClashImpact()
            }
        ])
        run(waitAndClash)
    }
    
    // MARK: - 3. 生成具備強烈五行象徵的拳招實體 (SKShapeNode + SKEmitterNode + Actions)
    
    /// 建立包含核心光球、漢字拳印、呼吸光環及專屬粒子尾跡的拳招節點
    /// - Parameters:
    ///   - element: 對應的五行元素
    ///   - isFacingRight: 是否面朝右側突進
    /// - Returns: 組裝完成的 SKNode
    private func makePunchNode(for element: FiveElement, isFacingRight: Bool) -> SKNode {
        let container = SKNode()
        let directionMultiplier: CGFloat = isFacingRight ? 1.0 : -1.0
        
        // 核心拳罡圓球
        let coreCircle = SKShapeNode(circleOfRadius: 32)
        coreCircle.fillColor = element.skColor
        coreCircle.strokeColor = element.skSecondaryColor
        coreCircle.lineWidth = 3.5
        coreCircle.glowWidth = 6
        container.addChild(coreCircle)
        
        // 拳印漢字標誌（採用俐方體像素字型）
        let charLabel = SKLabelNode(text: String(element.rawValue.first ?? "拳"))
        charLabel.fontName = "Cubic_11"
        charLabel.fontSize = 24
        charLabel.fontColor = .white
        charLabel.verticalAlignmentMode = .center
        charLabel.horizontalAlignmentMode = .center
        container.addChild(charLabel)
        
        // 外層呼吸氣旋光環
        let aura = SKShapeNode(circleOfRadius: 46)
        aura.strokeColor = element.skColor.withAlphaComponent(0.45)
        aura.lineWidth = 2
        container.addChild(aura)
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.18, duration: 0.4),
            SKAction.scale(to: 0.92, duration: 0.4)
        ]))
        aura.run(pulse)
        
        // 各自招式的專屬粒子與形狀演出
        switch element {
        case .metal:
            // 金·劈拳：神兵利刃刀芒出鞘，銳不可當
            let bladePath = CGMutablePath()
            bladePath.move(to: CGPoint(x: 0, y: -48))
            bladePath.addLine(to: CGPoint(x: directionMultiplier * 55, y: 0))
            bladePath.addLine(to: CGPoint(x: 0, y: 48))
            bladePath.closeSubpath()
            
            let blade = SKShapeNode(path: bladePath)
            blade.strokeColor = SKColor.white
            blade.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 0.6)
            blade.lineWidth = 2.5
            blade.glowWidth = 5
            container.addChild(blade)
            
            // 刀鋒閃光金芒閃爍
            let bladeGleam = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.2),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            ])
            blade.run(SKAction.repeatForever(bladeGleam))
            
            // 金屬火星尾跡發射器
            let sparkTrail = SKParticleFactory.makeTrailEmitter(
                texture: SKTextureGenerator.sparkStar(size: 26),
                color: element.skColor,
                birthRate: 50,
                speed: 70,
                scale: 0.45
            )
            sparkTrail.position = CGPoint(x: -directionMultiplier * 20, y: 0)
            sparkTrail.emissionAngle = isFacingRight ? .pi : 0
            container.addChild(sparkTrail)
            
        case .wood:
            // 木·崩拳：神木如槍，翡翠螺旋氣勁與青葉紛飛
            for i in 0..<3 {
                let spearRing = SKShapeNode(ellipseOf: CGSize(width: 25 + i * 15, height: 50 + i * 12))
                spearRing.strokeColor = element.skSecondaryColor
                spearRing.lineWidth = 2
                spearRing.position = CGPoint(x: directionMultiplier * CGFloat(20 + i * 18), y: 0)
                container.addChild(spearRing)
                spearRing.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.scale(to: 1.25, duration: 0.3),
                    SKAction.scale(to: 0.9, duration: 0.3)
                ])))
            }
            
            // 飛葉尾跡發射器
            let leafTrail = SKParticleFactory.makeTrailEmitter(
                texture: SKTextureGenerator.leaf(size: 28),
                color: element.skColor,
                birthRate: 40,
                speed: 60,
                scale: 0.5
            )
            leafTrail.position = CGPoint(x: -directionMultiplier * 20, y: 0)
            leafTrail.emissionAngle = isFacingRight ? .pi : 0
            container.addChild(leafTrail)
            
        case .water:
            // 水·鑽拳：如毒龍鑽水，深藍巨浪水龍捲旋渦
            let spiralWave = SKShapeNode(circleOfRadius: 40)
            spiralWave.fillColor = SKColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.4)
            spiralWave.strokeColor = SKColor.cyan
            spiralWave.lineWidth = 3
            container.addChild(spiralWave)
            spiralWave.run(SKAction.repeatForever(SKAction.rotate(byAngle: directionMultiplier * .pi * 2, duration: 0.6)))
            
            // 浪花飛濺水滴尾跡
            let waterTrail = SKParticleFactory.makeTrailEmitter(
                texture: SKTextureGenerator.waterDrop(size: 26),
                color: element.skSecondaryColor,
                birthRate: 45,
                speed: 80,
                scale: 0.45
            )
            waterTrail.position = CGPoint(x: -directionMultiplier * 20, y: 0)
            waterTrail.emissionAngle = isFacingRight ? .pi : 0
            container.addChild(waterTrail)
            
        case .fire:
            // 火·炮拳：炮火連天，如火龍噴吐烈焰與騰騰飛火
            let flameCore = SKShapeNode(circleOfRadius: 36)
            flameCore.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.05, alpha: 0.75)
            flameCore.strokeColor = SKColor.yellow
            flameCore.lineWidth = 4
            flameCore.glowWidth = 10
            container.addChild(flameCore)
            flameCore.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.15),
                SKAction.scale(to: 0.95, duration: 0.15)
            ])))
            
            // 烈焰煙塵粒子尾跡
            let fireTrail = SKParticleFactory.makeTrailEmitter(
                texture: SKTextureGenerator.smokePuff(size: 32),
                color: SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 0.8),
                birthRate: 60,
                speed: 90,
                scale: 0.55
            )
            fireTrail.position = CGPoint(x: -directionMultiplier * 20, y: 0)
            fireTrail.emissionAngle = isFacingRight ? .pi : 0
            container.addChild(fireTrail)
            
        case .earth:
            // 土·橫拳：如泰山壓頂，厚重土黃岩峰與奔騰碎石
            let rock = SKShapeNode(rectOf: CGSize(width: 55, height: 55), cornerRadius: 10)
            rock.fillColor = SKColor(red: 0.65, green: 0.45, blue: 0.25, alpha: 0.8)
            rock.strokeColor = element.skSecondaryColor
            rock.lineWidth = 3
            container.addChild(rock)
            rock.run(SKAction.repeatForever(SKAction.rotate(byAngle: directionMultiplier * .pi * 2, duration: 2.0)))
            
            // 碎石崩散煙塵發射器
            let rockTrail = SKParticleFactory.makeTrailEmitter(
                texture: SKTextureGenerator.rockShard(size: 26),
                color: element.skColor,
                birthRate: 35,
                speed: 55,
                scale: 0.45
            )
            rockTrail.position = CGPoint(x: -directionMultiplier * 20, y: 0)
            rockTrail.emissionAngle = isFacingRight ? .pi : 0
            container.addChild(rockTrail)
        }
        
        return container
    }
    
    // MARK: - 4. 拳勁對撞大爆炸 (Clash Impact Explosions & Screen Shake)
    
    /// 當雙方拳勁抵達交會點時觸發強烈爆炸反彈與鏡頭晃動
    private func triggerClashImpact() {
        guard !hasImpacted else { return }
        hasImpacted = true
        
        // 1. 雙拳急停衝擊反彈
        p1PunchNode?.run(SKAction.sequence([
            SKAction.moveBy(x: -25, y: 0, duration: 0.08),
            SKAction.scale(to: 1.3, duration: 0.1)
        ]))
        p2PunchNode?.run(SKAction.sequence([
            SKAction.moveBy(x: 25, y: 0, duration: 0.08),
            SKAction.scale(to: 1.3, duration: 0.1)
        ]))
        
        // 2. 白色全螢幕衝擊光波擴散圈
        let shockwave = SKShapeNode(circleOfRadius: 20)
        shockwave.position = .zero
        shockwave.strokeColor = .white
        shockwave.lineWidth = 8
        shockwave.glowWidth = 14
        worldNode.addChild(shockwave)
        
        shockwave.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 18.0, duration: 0.45),
                SKAction.fadeOut(withDuration: 0.45)
            ]),
            SKAction.removeFromParent()
        ]))
        
        // 3. 雙方元素色彩交融大爆發粒子
        let burst1 = SKParticleFactory.makeBurstEmitter(
            texture: SKTextureGenerator.sparkStar(size: 32),
            color: p1Element.skColor,
            count: 45,
            speed: 380,
            scale: 0.65
        )
        burst1.position = .zero
        worldNode.addChild(burst1)
        
        let burst2 = SKParticleFactory.makeBurstEmitter(
            texture: SKTextureGenerator.sparkStar(size: 32),
            color: p2Element.skColor,
            count: 45,
            speed: 380,
            scale: 0.65
        )
        burst2.position = .zero
        worldNode.addChild(burst2)
        
        // 4. 震撼螢幕晃動
        worldNode.run(SKAnimationHelper.screenShake(amplitude: 14, duration: 0.4))
        
        // 5. 衝擊完成後延遲 0.8 秒回調通知過渡到生剋結果
        let completeAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.run { [weak self] in
                self?.onClashComplete?()
            }
        ])
        run(completeAction)
    }
}

// MARK: - SwiftUI 出拳發勁全螢幕展示視圖 (FullScreenPunchShowdownView)

/// 封裝 SpriteKitPunchScene 並提供上方對戰抬頭名牌（HUD）與下方操作按鈕（重播、看結果、關閉）的 SwiftUI 容器視圖
struct FullScreenPunchShowdownView: View {
    /// 左方選手姓名
    let p1Name: String
    /// 左方選手五行
    let p1Element: FiveElement
    /// 右方選手姓名
    let p2Name: String
    /// 右方選手五行
    let p2Element: FiveElement
    /// 關閉退出視圖回呼
    var onDismiss: (() -> Void)? = nil
    /// 推進至生剋結果階段之回呼
    let onTransitionToClash: () -> Void
    
    /// 用於強制刷新重播 SpriteKit 場景的 UUID
    @State private var sceneId = UUID()
    /// 防止重複觸發切換頁面的標記
    @State private var hasAutoNavigated = false
    
    /// 標準初始化方法
    init(
        p1Name: String,
        p1Element: FiveElement,
        p2Name: String,
        p2Element: FiveElement,
        onDismiss: (() -> Void)? = nil,
        onTransitionToClash: @escaping () -> Void
    ) {
        self.p1Name = p1Name
        self.p1Element = p1Element
        self.p2Name = p2Name
        self.p2Element = p2Element
        self.onDismiss = onDismiss
        self.onTransitionToClash = onTransitionToClash
    }
    
    /// 相容性初始化方法（接受 source/target 命名慣例）
    init(
        sourceName: String,
        sourceElement: FiveElement,
        targetName: String,
        targetElement: FiveElement,
        onDismiss: (() -> Void)? = nil,
        onClash: @escaping () -> Void
    ) {
        self.p1Name = sourceName
        self.p1Element = sourceElement
        self.p2Name = targetName
        self.p2Element = targetElement
        self.onDismiss = onDismiss
        self.onTransitionToClash = onClash
    }
    
    var body: some View {
        ZStack {
            // SpriteKit 60fps 高效能全螢幕出拳場景，透過 GeometryReader 精準傳遞畫面尺寸
            GeometryReader { proxy in
                let size = proxy.size.width > 0 && proxy.size.height > 0
                    ? proxy.size
                    : CGSize(width: 400, height: 800)
                
                SpriteView(
                    scene: makeScene(size: size),
                    preferredFramesPerSecond: 60,
                    options: [.allowsTransparency]
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .id(sceneId)
            }
            .ignoresSafeArea()
            
            // 全螢幕 HUD 覆蓋層
            VStack {
                // 上方 HUD：對決雙方出拳武功稱號
                HStack(alignment: .top) {
                    // P1 出拳名片
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p1Name)
                            .font(.elementChinese(size: 16))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(p1Element.primaryColor)
                                .frame(width: 12, height: 12)
                            Text(p1Element.attackName)
                                .font(.elementChinese(size: 13))
                                .fontWeight(.bold)
                                .foregroundColor(p1Element.primaryColor)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(p1Element.primaryColor.opacity(0.5), lineWidth: 1.5)
                    )
                    
                    Spacer()
                    
                    // 中間 VS 徽章
                    VStack(spacing: 2) {
                        Text("VS")
                            .font(.elemental(size: 20))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 4)
                        Text("第一幕 · 蓄勢出拳")
                            .font(.elementChinese(size: 10))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // P2 出拳名片
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(p2Name)
                            .font(.elementChinese(size: 16))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Text(p2Element.attackName)
                                .font(.elementChinese(size: 13))
                                .fontWeight(.bold)
                                .foregroundColor(p2Element.primaryColor)
                            Circle()
                                .fill(p2Element.primaryColor)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(p2Element.primaryColor.opacity(0.5), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Spacer()
                
                // 下方控制列：返回棋盤、重放、跳過觀看生剋
                HStack(spacing: 12) {
                    if let onDismiss = onDismiss {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onDismiss()
                            }
                        } label: {
                            Label("返回棋盤", systemImage: "xmark.circle")
                                .font(.elementChinese(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        // 重播當前出拳動畫
                        hasAutoNavigated = false
                        sceneId = UUID()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重排發勁")
                        }
                        .font(.elementChinese(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    
                    Button {
                        advanceToClash()
                    } label: {
                        HStack(spacing: 6) {
                            Text("看生剋結果")
                            Image(systemName: "forward.fill")
                        }
                        .font(.elementChinese(size: 13))
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .yellow.opacity(0.5), radius: 6)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
    }
    
    /// 依據最新尺寸建立 SpriteKitPunchScene 實體
    private func makeScene(size: CGSize) -> SKScene {
        SpriteKitPunchScene(
            size: size,
            p1Name: p1Name,
            p1Element: p1Element,
            p2Name: p2Name,
            p2Element: p2Element,
            onClashComplete: {
                advanceToClash()
            }
        )
    }
    
    /// 推進至生剋結果視圖
    private func advanceToClash() {
        guard !hasAutoNavigated else { return }
        hasAutoNavigated = true
        withAnimation(.easeInOut(duration: 0.35)) {
            onTransitionToClash()
        }
    }
}
