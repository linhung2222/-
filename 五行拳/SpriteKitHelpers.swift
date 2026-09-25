//
//  SpriteKitHelpers.swift
//  五行拳
//
//  SpriteKit 特效輔助模組
//  提供純程式碼 CoreGraphics 紋理動態生成、SpriteKit 粒子發射器工廠、畫面震動特效以及五行專屬色彩轉換
//

import SwiftUI
import SpriteKit

// MARK: - 跨平台 CoreGraphics 紋理生成器

/// 透過 CoreGraphics 於記憶體中即時繪製並生成 SpriteKit 紋理（SKTexture）的工具列舉
/// 免除外部圖檔資源依賴，以數學曲線動態繪製高品質光暈、星光、落葉、水滴與碎石紋理
enum SKTextureGenerator {
    
    /// 在記憶體中建立 CGContext 畫布，執行自訂繪圖閉包後輸出為 SKTexture
    /// - Parameters:
    ///   - size: 紋理的畫布寬高尺寸（CGSize）
    ///   - drawing: 繪圖閉包，傳入已初始化的 CGContext 供繪製幾何路徑與漸層
    /// - Returns: 生成完成的 SpriteKit 紋理物件；若 context 建立失敗則回傳空紋理
    static func createTexture(size: CGSize, drawing: (CGContext) -> Void) -> SKTexture {
        let width = max(1, Int(size.width))
        let height = max(1, Int(size.height))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        // 建立 32 位元 RGBA 點陣圖上下文
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return SKTexture()
        }
        
        // 清除畫布背景為全透明
        context.clear(CGRect(origin: .zero, size: size))
        // 執行外部繪製邏輯
        drawing(context)
        
        // 匯出為 CGImage 並封裝為 SKTexture
        if let cgImage = context.makeImage() {
            return SKTexture(cgImage: cgImage)
        }
        return SKTexture()
    }
    
    /// 柔光光暈圓形粒子紋理 (Radial Glow Circle)
    /// 常用於相生靈氣、能量凝聚與氣功衝擊波的中心光暈
    /// - Parameter size: 紋理尺寸（預設為 48 點）
    /// - Returns: 中心高亮向外遞減透明之圓形漸層紋理
    static func glowCircle(size: CGFloat = 48) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            // 由中心純白（不透明）過渡至邊緣完全透明
            let colors: [CGFloat] = [
                1.0, 1.0, 1.0, 1.0,
                1.0, 1.0, 1.0, 0.5,
                1.0, 1.0, 1.0, 0.0
            ]
            let locations: [CGFloat] = [0.0, 0.4, 1.0]
            if let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: locations, count: 3) {
                ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
            }
        }
    }
    
    /// 四芒金色／白色星光紋理 (Spark Star)
    /// 具備銳利星芒造型，適合用於金石相撞之火花、生剋爆發與高光閃爍
    /// - Parameter size: 紋理尺寸（預設為 36 點）
    /// - Returns: 四角星芒之向量紋理
    static func sparkStar(size: CGFloat = 36) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            let center = CGPoint(x: size / 2, y: size / 2)
            let rInner = size * 0.18 // 內縮控制點半徑
            
            // 使用二次貝茲曲線繪製向內凹陷的四角星形
            ctx.move(to: CGPoint(x: center.x, y: 0))
            ctx.addQuadCurve(to: CGPoint(x: size, y: center.y), control: CGPoint(x: center.x + rInner, y: center.y - rInner))
            ctx.addQuadCurve(to: CGPoint(x: center.x, y: size), control: CGPoint(x: center.x + rInner, y: center.y + rInner))
            ctx.addQuadCurve(to: CGPoint(x: 0, y: center.y), control: CGPoint(x: center.x - rInner, y: center.y + rInner))
            ctx.addQuadCurve(to: CGPoint(x: center.x, y: 0), control: CGPoint(x: center.x - rInner, y: center.y - rInner))
            ctx.closePath()
            
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            ctx.fillPath()
        }
    }
    
    /// 青木靈葉紋理 (Leaf)
    /// 呈現微彎靈動的樹葉輪廓，專用於木系崩拳及「木生火」、「金剋木」落葉特效
    /// - Parameter size: 紋理尺寸（預設為 36 點）
    /// - Returns: 葉片形狀紋理
    static func leaf(size: CGFloat = 36) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            ctx.move(to: CGPoint(x: size * 0.5, y: 0))
            // 繪製左右兩側平滑外拱之弧線
            ctx.addQuadCurve(to: CGPoint(x: size * 0.5, y: size), control: CGPoint(x: size * 0.95, y: size * 0.4))
            ctx.addQuadCurve(to: CGPoint(x: size * 0.5, y: 0), control: CGPoint(x: size * 0.05, y: size * 0.6))
            ctx.closePath()
            
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            ctx.fillPath()
        }
    }
    
    /// 水滴滴落紋理 (Water Drop)
    /// 上尖下圓之水滴外觀，專用於水系鑽拳、波濤飛濺與「水剋火」狂浪特效
    /// - Parameter size: 紋理尺寸（預設為 36 點）
    /// - Returns: 水滴幾何形狀紋理
    static func waterDrop(size: CGFloat = 36) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            ctx.move(to: CGPoint(x: size * 0.5, y: 0))
            // 右側下拋線
            ctx.addCurve(to: CGPoint(x: size, y: size * 0.7), control1: CGPoint(x: size * 0.85, y: size * 0.3), control2: CGPoint(x: size, y: size * 0.5))
            // 底部圓弧
            ctx.addArc(center: CGPoint(x: size * 0.5, y: size * 0.7), radius: size * 0.5, startAngle: 0, endAngle: .pi, clockwise: false)
            // 左側上收線
            ctx.addCurve(to: CGPoint(x: size * 0.5, y: 0), control1: CGPoint(x: 0, y: size * 0.5), control2: CGPoint(x: size * 0.15, y: size * 0.3))
            ctx.closePath()
            
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            ctx.fillPath()
        }
    }
    
    /// 碎石塊紋理 (Rock Shard)
    /// 多邊形不規則碎石塊造型，專用於土系橫拳及土崩石裂之撞擊特效
    /// - Parameter size: 紋理尺寸（預設為 32 點）
    /// - Returns: 不規則多邊形岩塊紋理
    static func rockShard(size: CGFloat = 32) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            ctx.move(to: CGPoint(x: size * 0.3, y: size * 0.05))
            ctx.addLine(to: CGPoint(x: size * 0.85, y: size * 0.2))
            ctx.addLine(to: CGPoint(x: size * 0.95, y: size * 0.75))
            ctx.addLine(to: CGPoint(x: size * 0.6, y: size * 0.95))
            ctx.addLine(to: CGPoint(x: size * 0.1, y: size * 0.7))
            ctx.addLine(to: CGPoint(x: size * 0.05, y: size * 0.35))
            ctx.closePath()
            
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            ctx.fillPath()
        }
    }
    
    /// 煙霧蓬鬆紋理 (Smoke Puff)
    /// 柔軟蓬鬆之煙霧團球，專用於碰撞後騰起之白霧或揚塵
    /// - Parameter size: 紋理尺寸（預設為 44 點）
    /// - Returns: 蓬鬆煙霧徑向漸層紋理
    static func smokePuff(size: CGFloat = 44) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors: [CGFloat] = [
                1.0, 1.0, 1.0, 0.65,
                1.0, 1.0, 1.0, 0.25,
                1.0, 1.0, 1.0, 0.0
            ]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]
            if let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: locations, count: 3) {
                ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
            }
        }
    }
}

// MARK: - 常用 SpriteKit 粒子發射器工廠

/// 封裝各種戰鬥動態特效之粒子發射器節點（SKEmitterNode）工廠
enum SKParticleFactory {
    
    /// 通用單次爆發粒子發射器（用於出拳衝擊、金光破空、火星四濺、水珠迸發等）
    /// - Parameters:
    ///   - texture: 粒子使用的紋理
    ///   - color: 粒子主色調
    ///   - count: 發射的粒子總數（預設 30）
    ///   - speed: 粒子初始噴射速度（預設 260 點/秒）
    ///   - lifetime: 粒子存活秒數（預設 0.85 秒）
    ///   - scale: 初始縮放倍率（預設 0.6）
    /// - Returns: 配置完成的 SKEmitterNode 物件
    static func makeBurstEmitter(
        texture: SKTexture,
        color: SKColor,
        count: Int = 30,
        speed: CGFloat = 260,
        lifetime: CGFloat = 0.85,
        scale: CGFloat = 0.6
    ) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = texture
        // 短時間內密集噴射完畢，呈現爆發感
        emitter.particleBirthRate = CGFloat(count) / 0.15
        emitter.numParticlesToEmit = count
        emitter.particleLifetime = lifetime
        emitter.particleLifetimeRange = lifetime * 0.3
        emitter.particlePositionRange = CGVector(dx: 15, dy: 15)
        
        // 360 度無死角全方位爆散
        emitter.particleSpeed = speed
        emitter.particleSpeedRange = speed * 0.5
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        // 顏色與加法光效混合模式（增強發光立體感）
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        // 縮放漸小至消失
        emitter.particleScale = scale
        emitter.particleScaleRange = scale * 0.3
        emitter.particleScaleSpeed = -scale / lifetime
        
        // 透明度漸變衰減
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.0 / lifetime
        
        return emitter
    }
    
    /// 持續尾跡發射器（用於拳招飛行路徑之流光尾痕）
    /// - Parameters:
    ///   - texture: 尾跡粒子紋理
    ///   - color: 尾跡色彩
    ///   - birthRate: 每秒生成粒子數（預設 45）
    ///   - speed: 尾跡散開速度（預設 40 點/秒）
    ///   - lifetime: 尾跡留存時間（預設 0.5 秒）
    ///   - scale: 尾跡縮放大小（預設 0.4）
    /// - Returns: SKEmitterNode 尾跡發射器節點
    static func makeTrailEmitter(
        texture: SKTexture,
        color: SKColor,
        birthRate: CGFloat = 45,
        speed: CGFloat = 40,
        lifetime: CGFloat = 0.5,
        scale: CGFloat = 0.4
    ) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = texture
        emitter.particleBirthRate = birthRate
        emitter.particleLifetime = lifetime
        emitter.particleLifetimeRange = 0.15
        emitter.particlePositionRange = CGVector(dx: 10, dy: 10)
        
        // 朝後方扇形噴發
        emitter.particleSpeed = speed
        emitter.particleSpeedRange = speed * 0.4
        emitter.emissionAngle = .pi
        emitter.emissionAngleRange = .pi / 4
        
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        emitter.particleScale = scale
        emitter.particleScaleRange = scale * 0.25
        emitter.particleScaleSpeed = -scale / lifetime
        
        emitter.particleAlpha = 0.85
        emitter.particleAlphaSpeed = -0.85 / lifetime
        
        return emitter
    }
    
    /// 相生滋養光環上升粒子噴泉（Healing Aura Fountain）
    /// 用於相生觸發時，由下而上緩緩升騰之翠綠或蔚藍靈氣
    /// - Parameter color: 靈氣光暈色彩
    /// - Returns: 上升飄渺之靈氣發射器節點
    static func makeHealFountainEmitter(color: SKColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTextureGenerator.sparkStar(size: 28)
        emitter.particleBirthRate = 50
        emitter.particleLifetime = 1.4
        emitter.particleLifetimeRange = 0.4
        emitter.particlePositionRange = CGVector(dx: 70, dy: 15)
        
        // 向上方垂直升騰（90 度，微幅扇形散開）
        emitter.particleSpeed = 120
        emitter.particleSpeedRange = 40
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi / 6
        
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.15
        
        emitter.particleAlpha = 0.95
        emitter.particleAlphaSpeed = -0.6
        
        return emitter
    }
}

// MARK: - 特效動作輔助（鏡頭震動與閃光）

/// 動畫動作輔助類別
enum SKAnimationHelper {
    
    /// 產生震撼打擊感的鏡頭隨機晃動動作（Screen Shake）
    /// - Parameters:
    ///   - amplitude: 晃動最大振幅偏移量（點，points，預設 12）
    ///   - duration: 震動持續時間（秒，預設 0.35 秒）
    /// - Returns: 由一連串快速位移組成的 SKAction 序列
    static func screenShake(amplitude: CGFloat = 12, duration: TimeInterval = 0.35) -> SKAction {
        let numberOfShakes = Int(duration / 0.04)
        var actions: [SKAction] = []
        for _ in 0..<numberOfShakes {
            let dx = CGFloat.random(in: -amplitude...amplitude)
            let dy = CGFloat.random(in: -amplitude...amplitude)
            // 往隨機方向偏移後立即復位，模擬劇烈衝擊波震動
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: 0.04))
            actions.append(SKAction.moveBy(x: -dx, y: -dy, duration: 0.04))
        }
        return SKAction.sequence(actions)
    }
}

// MARK: - FiveElement 轉 SpriteKit 顏色擴充

extension FiveElement {
    
    /// 將五行元素轉換為 SpriteKit 原生之 SKColor（iOS 環境下即為 UIColor）
    var skColor: SKColor {
        switch self {
        case .metal:
            return SKColor(red: 1.0, green: 0.84, blue: 0.3, alpha: 1.0)
        case .wood:
            return SKColor(red: 0.25, green: 0.85, blue: 0.4, alpha: 1.0)
        case .water:
            return SKColor(red: 0.2, green: 0.65, blue: 1.0, alpha: 1.0)
        case .fire:
            return SKColor(red: 1.0, green: 0.32, blue: 0.15, alpha: 1.0)
        case .earth:
            return SKColor(red: 0.85, green: 0.62, blue: 0.35, alpha: 1.0)
        }
    }
    
    /// 五行元素於 SpriteKit 特效中所使用之高亮輔助色彩
    var skSecondaryColor: SKColor {
        switch self {
        case .metal:
            return SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        case .wood:
            return SKColor(red: 0.55, green: 0.95, blue: 0.6, alpha: 1.0)
        case .water:
            return SKColor(red: 0.5, green: 0.85, blue: 1.0, alpha: 1.0)
        case .fire:
            return SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        case .earth:
            return SKColor(red: 0.92, green: 0.78, blue: 0.55, alpha: 1.0)
        }
    }
}
