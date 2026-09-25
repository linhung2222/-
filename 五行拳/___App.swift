//
//  五行拳App.swift
//  五行拳
//

import SwiftUI
import UIKit

@main
struct WuXingQuanApp: App {
    init() {
        // 設定全域 UIKit 原生元件（導覽列標題、分段控制器等）採用元素主題字體
        if let navFont = UIFont(name: "Cubic_11", size: 18) {
            UINavigationBar.appearance().titleTextAttributes = [.font: navFont]
        }
        if let largeNavFont = UIFont(name: "Cubic_11", size: 28) {
            UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeNavFont]
        }
        if let segmentFont = UIFont(name: "Cubic_11", size: 12) {
            UISegmentedControl.appearance().setTitleTextAttributes([.font: segmentFont], for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes([.font: segmentFont], for: .selected)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(.custom("Cubic_11", size: 15))
        }
    }
}
