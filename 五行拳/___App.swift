//
//  五行拳App.swift
//  五行拳
//
//  應用程式進入點與全域樣式初始化模組
//

import SwiftUI
import UIKit

/// 五行拳應用程式的主進入點（App Entry Point）
/// 遵循 SwiftUI 的 App 協定，負責初始化全域環境與外觀設定
@main
struct WuXingQuanApp: App {
    
    /// 初始化應用程式並配置全域 UIKit 原生元件的樣式與字型
    init() {
        // 設定全域 UIKit 導覽列（UINavigationBar）標準標題之字型為「俐方體 11 號 (Cubic_11)」
        if let navFont = UIFont(name: "Cubic_11", size: 18) {
            UINavigationBar.appearance().titleTextAttributes = [.font: navFont]
        }
        
        // 設定全域 UIKit 導覽列大標題（Large Title）之字型為「俐方體 11 號 (Cubic_11)」
        if let largeNavFont = UIFont(name: "Cubic_11", size: 28) {
            UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeNavFont]
        }
        
        // 設定全域分段控制器（UISegmentedControl）於一般與選中狀態下的文字字型
        if let segmentFont = UIFont(name: "Cubic_11", size: 12) {
            UISegmentedControl.appearance().setTitleTextAttributes([.font: segmentFont], for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes([.font: segmentFont], for: .selected)
        }
    }
    
    /// 應用程式主場景架構
    var body: some Scene {
        WindowGroup {
            // 載入應用程式主畫面，並預設採用元素主題像素字型
            ContentView()
                .font(.custom("Cubic_11", size: 15))
        }
    }
}
