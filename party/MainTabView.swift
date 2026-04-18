//
//  MainTabView.swift
//  party
//
//  Created by 窝是菜蛋 on 2025/09/28.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            //主页
            AppListView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("主页")
                }
                .tag(0)
            
            //关于页面
            AboutView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "info.circle.fill" : "info.circle")
                    Text("关于")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
}

