//
//  SpriteKitHelpers.swift
//  五行拳
//

import SwiftUI
import SpriteKit

// MARK: - 跨平台 CoreGraphics 紋理生成器
enum SKTextureGenerator {
    
    /// 生成純內存 CGContext 並輸出 SKTexture
    static func createTexture(size: CGSize, drawing: (CGContext) -> Void) -> SKTexture {
        let width = max(1, Int(size.width))
        let height = max(1, Int(size.height))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
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
        
        context.clear(CGRect(origin: .zero, size: size))
        drawing(context)
        
        if let cgImage = context.makeImage() {
            return SKTexture(cgImage: cgImage)
        }
        return SKTexture()
    }
    
    /// 柔光光暈圓形粒子紋理 (Radial Glow Circle)
    static func glowCircle(size: CGFloat = 48) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2
            let colorSpace = CGColorSpaceCreateDeviceRGB()
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
    
    /// 四芒金色/白色星光紋理 (Spark Star)
    static func sparkStar(size: CGFloat = 36) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            let center = CGPoint(x: size / 2, y: size / 2)
            let rInner = size * 0.18
            
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
    static func leaf(size: CGFloat = 36) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            ctx.move(to: CGPoint(x: size * 0.5, y: 0))
            ctx.addQuadCurve(to: CGPoint(x: size * 0.5, y: size), control: CGPoint(x: size * 0.95, y: size * 0.4))
            ctx.addQuadCurve(to: CGPoint(x: size * 0.5, y: 0), control: CGPoint(x: size * 0.05, y: size * 0.6))
            ctx.closePath()
            
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            ctx.fillPath()
        }
    }
    
    /// 水滴滴落紋理 (Water Drop)
    static func waterDrop(size: CGFloat = 36) -> SKTexture {
        createTexture(size: CGSize(width: size, height: size)) { ctx in
            ctx.move(to: CGPoint(x: size * 0.5, y: 0))
            ctx.addCurve(to: CGPoint(x: size, y: size * 0.7), control1: CGPoint(x: size * 0.85, y: size * 0.3), control2: CGPoint(x: size, y: size * 0.5))
            ctx.addArc(center: CGPoint(x: size * 0.5, y: size * 0.7), radius: size * 0.5, startAngle: 0, endAngle: .pi, clockwise: false)
            ctx.addCurve(to: CGPoint(x: size * 0.5, y: 0), control1: CGPoint(x: 0, y: size * 0.5), control2: CGPoint(x: size * 0.15, y: size * 0.3))
            ctx.closePath()
            
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
            ctx.fillPath()
        }
    }
    
    /// 碎石塊紋理 (Rock Shard)
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
enum SKParticleFactory {
    
    /// 通用爆發粒子發射器 (金光、火星、水珠、綠葉、塵土)
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
        emitter.particleBirthRate = CGFloat(count) / 0.15
        emitter.numParticlesToEmit = count
        emitter.particleLifetime = lifetime
        emitter.particleLifetimeRange = lifetime * 0.3
        emitter.particlePositionRange = CGVector(dx: 15, dy: 15)
        
        emitter.particleSpeed = speed
        emitter.particleSpeedRange = speed * 0.5
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        
        emitter.particleScale = scale
        emitter.particleScaleRange = scale * 0.3
        emitter.particleScaleSpeed = -scale / lifetime
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.0 / lifetime
        
        return emitter
    }
    
    /// 持續尾跡發射器 (Trailing Emitter)
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
    
    /// 生滋養光環上升粒子 (Healing Aura Fountain)
    static func makeHealFountainEmitter(color: SKColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTextureGenerator.sparkStar(size: 28)
        emitter.particleBirthRate = 50
        emitter.particleLifetime = 1.4
        emitter.particleLifetimeRange = 0.4
        emitter.particlePositionRange = CGVector(dx: 70, dy: 15)
        
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

// MARK: - 特效動畫輔助 (Screen Shake & Flash)
enum SKAnimationHelper {
    
    /// 震撼鏡頭晃動 Action
    static func screenShake(amplitude: CGFloat = 12, duration: TimeInterval = 0.35) -> SKAction {
        let numberOfShakes = Int(duration / 0.04)
        var actions: [SKAction] = []
        for _ in 0..<numberOfShakes {
            let dx = CGFloat.random(in: -amplitude...amplitude)
            let dy = CGFloat.random(in: -amplitude...amplitude)
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: 0.04))
            actions.append(SKAction.moveBy(x: -dx, y: -dy, duration: 0.04))
        }
        return SKAction.sequence(actions)
    }
}

// MARK: - FiveElement 轉 SpriteKit 顏色輔助
extension FiveElement {
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
