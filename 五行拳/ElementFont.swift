//
//  ElementFont.swift
//  五行拳
//

import SwiftUI

extension Font {
    /// 元素主題英文字體（ELEMENTAL - 霸氣幾何元素風格）
    static func elemental(size: CGFloat) -> Font {
        Font.custom("ELEMENTAL", size: size)
    }
    
    /// 元素主題中文字體（俐方體 11 號 - 完整收錄元素週期表漢字與五行字符之開源像素風字體）
    static func elementChinese(size: CGFloat) -> Font {
        Font.custom("Cubic_11", size: size)
    }
    
    /// 元素手寫流動藝術字體（Elements）
    static func elementsArt(size: CGFloat) -> Font {
        Font.custom("Elements", size: size)
    }
    
    /// 元素主題主要標題字體
    static func elementTitle(size: CGFloat) -> Font {
        Font.custom("Cubic_11", size: size)
    }
    
    /// 元素主題內文字體
    static func elementBody(size: CGFloat) -> Font {
        Font.custom("Cubic_11", size: size)
    }
    
    // MARK: - 元素語意化字型等級（全面採用 Cubic_11 元素字體）
    static var elementLargeTitle: Font { .custom("Cubic_11", size: 32) }
    static var elementTitle1: Font { .custom("Cubic_11", size: 26) }
    static var elementTitle2: Font { .custom("Cubic_11", size: 22) }
    static var elementTitle3: Font { .custom("Cubic_11", size: 19) }
    static var elementHeadline: Font { .custom("Cubic_11", size: 16) }
    static var elementSubheadline: Font { .custom("Cubic_11", size: 14) }
    static var elementBodyText: Font { .custom("Cubic_11", size: 15) }
    static var elementCallout: Font { .custom("Cubic_11", size: 14) }
    static var elementFootnote: Font { .custom("Cubic_11", size: 13) }
    static var elementCaption: Font { .custom("Cubic_11", size: 12) }
    static var elementCaption2: Font { .custom("Cubic_11", size: 10) }
    
    // MARK: - 元素英文字體等級（ELEMENTAL）
    static var elementalHeadline: Font { .custom("ELEMENTAL", size: 16) }
    static var elementalTitle: Font { .custom("ELEMENTAL", size: 20) }
    static var elementalLargeTitle: Font { .custom("ELEMENTAL", size: 28) }
}
