//
//  NavigationRoutingView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import SwiftUI

struct NavigationRoutingView: View {
    @EnvironmentObject var container: DIContainer
    @State var destination: NavigationDestination
    
    var body: some View {
        switch destination {
        case let .chat(chatRoomId, myUserId, otherUserId):
            ChatView(viewModel: .init(chatRoomId: chatRoomId, myUserId: myUserId, otherUserId: otherUserId, container: container))
        case .search:
            SearchView()
        }
    }
}
