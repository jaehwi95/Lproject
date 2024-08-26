//
//  ChatView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
        ScrollView {
            contentView
        }
        .background(Color.chatBg)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(
                    action: {
                        navigationRouter.pop()
                    },
                    label: {
                        Image("back")
                    }
                )
                Text(viewModel.otherUser?.name ?? "대화방이름")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.bkText)
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Image("search_chat")
                Image("bookmark")
                Image("settings")
            }
        }
    }
    
    var contentView: some View {
        EmptyView()
    }
}

#Preview {
    NavigationStack {
        ChatView(
            viewModel: .init(
                chatRoomId: "chatRoom1_id",
                myUserId: "user1_id",
                otherUserId: "user2_id",
                container: DIContainer(
                    services: StubService()
                )
            )
        )
    }
}
