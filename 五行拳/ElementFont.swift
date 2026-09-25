//
//  ElementFont.swift
//  五行拳
//
//  五行元素風格字型擴充模組
//  定義應用程式內專用之像素風格（俐方體）、幾何元素英文（ELEMENTAL）以及藝術字體
//

import SwiftUI

extension Font {
    
    // MARK: - 自訂字型生成方法
    
    /// 元素主題英文字體（ELEMENTAL）
    /// - Parameter size: 字型大小（點數，points）
    /// - Returns: 套用 ELEMENTAL 字型的 SwiftUI Font 物件，具備霸氣俐落的幾何科技與元素風格
    static func elemental(size: CGFloat) -> Font {
        Font.custom("ELEMENTAL", size: size)
    }
    
    /// 元素主題中文字體（俐方體 11 號 - Cubic 11）
    /// - Parameter size: 字型大小（點數，points）
    /// - Returns: 套用 Cubic_11 字型的 SwiftUI Font 物件；該字型為開源像素風字體，完整支援繁體中文五行生剋與武術專用字詞
    static func elementChinese(size: CGFloat) -> Font {
        Font.custom("Cubic_11", size: size)
    }
    
    /// 元素手寫流動藝術字體（Elements）
    /// - Parameter size: 字型大小（點數，points）
    /// - Returns: 套用 Elements 手寫流動字型的 SwiftUI Font 物件，適合用於封面美術標題與詩意落款
    static func elementsArt(size: CGFloat) -> Font {
        Font.custom("Elements", size: size)
    }
    
    /// 元素主題主要標題字體（基於 Cubic_11）
    /// - Parameter size: 標題字型大小
    /// - Returns: 元素風格標題字型
    static func elementTitle(size: CGFloat) -> Font {
        Font.custom("Cubic_11", size: size)
    }
    
    /// 元素主題內文字體（基於 Cubic_11）
    /// - Parameter size: 內文字型大小
    /// - Returns: 元素風格內文字型
    static func elementBody(size: CGFloat) -> Font {
        Font.custom("Cubic_11", size: size)
    }
    
    // MARK: - 元素語意化字型等級（全面採用 Cubic_11 像素字體）
    
    /// 特大標題（Large Title, 32pt），用於主畫面最顯眼之大標題
    static var elementLargeTitle: Font { .custom("Cubic_11", size: 32) }
    
    /// 一級標題（Title 1, 26pt），用於各模組首要區塊標題
    static var elementTitle1: Font { .custom("Cubic_11", size: 26) }
    
    /// 二級標題（Title 2, 22pt），用於卡片標題或對決結果提示
    static var elementTitle2: Font { .custom("Cubic_11", size: 22) }
    
    /// 三級標題（Title 3, 19pt），用於副區塊或彈出視窗標題
    static var elementTitle3: Font { .custom("Cubic_11", size: 19) }
    
    /// 精選粗體標題（Headline, 16pt），用於強調之資訊或玩家名稱
    static var elementHeadline: Font { .custom("Cubic_11", size: 16) }
    
    /// 次標題（Subheadline, 14pt），用於欄位輔助標題
    static var elementSubheadline: Font { .custom("Cubic_11", size: 14) }
    
    /// 標準正文內文（Body Text, 15pt），用於對戰過程敘述與一般說明
    static var elementBodyText: Font { .custom("Cubic_11", size: 15) }
    
    /// 提示文字（Callout, 14pt），用於引導操作之輔助說明
    static var elementCallout: Font { .custom("Cubic_11", size: 14) }
    
    /// 腳註文字（Footnote, 13pt），用於底部註記或回合歷史補充
    static var elementFootnote: Font { .custom("Cubic_11", size: 13) }
    
    /// 圖例說明（Caption, 12pt），用於小標籤或數值計數
    static var elementCaption: Font { .custom("Cubic_11", size: 12) }
    
    /// 迷你圖例說明（Caption 2, 10pt），用於極小尺寸之狀態徽記
    static var elementCaption2: Font { .custom("Cubic_11", size: 10) }
    
    // MARK: - 元素英文字體等級（ELEMENTAL 幾何英數字體）
    
    /// 英文字體粗體標題（Headline, 16pt），適用於英數狀態數值
    static var elementalHeadline: Font { .custom("ELEMENTAL", size: 16) }
    
    /// 英文字體中型標題（Title, 20pt），適用於回合數或血量變化展示
    static var elementalTitle: Font { .custom("ELEMENTAL", size: 20) }
    
    /// 英文字體大標題（Large Title, 28pt），適用於勝負總結或全螢幕倒數計時
    static var elementalLargeTitle: Font { .custom("ELEMENTAL", size: 28) }
}
