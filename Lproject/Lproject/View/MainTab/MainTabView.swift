//
//  MainTabView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/13.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab: MainTabType = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                switch tab {
                case .home:
                    EmptyView()
                case .chat:
                    EmptyView()
                case .phone:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
