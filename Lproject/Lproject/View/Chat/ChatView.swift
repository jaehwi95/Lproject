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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView {
            if viewModel.chatDataList.isEmpty {
                Color.chatBg
            } else {
                contentView
            }
        }
        .background(Color.chatBg)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(Color.chatBg, for: .navigationBar)
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
        .keyboardToolbar(height: 50) {
            HStack(spacing: 13) {
                Button(
                    action: {
                        
                    },
                    label: {
                        Image("other_add")
                    }
                )
                Button(
                    action: {
                        
                    },
                    label: {
                        Image("image_add")
                    }
                )
                Button(
                    action: {
                        
                    },
                    label: {
                        Image("photo_camera")
                    }
                )
                
                TextField("", text: $viewModel.message)
                    .font(.system(size: 16))
                    .foregroundColor(.bkText)
                    .focused($isFocused)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .background(Color.greyCool)
                    .cornerRadius(20)
                Button(
                    action: {
                        
                    },
                    label: {
                        Image("send")
                    }
                )
            }
            .padding(.horizontal, 27)
        }
    }
    
    var contentView: some View {
        ForEach(viewModel.chatDataList) { chatData in
            Section {
                ForEach(chatData.chats) { chat in
                    ChatItemView(
                        message: chat.message ?? "",
                        direction: viewModel.getDirection(id: chat.userId),
                        date: chat.date
                    )
                }
            } header: {
                headerView(dateString: chatData.dateString)
            }
        }
    }
    
    func headerView(dateString: String) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 76, height: 20)
                .background(Color.chatNotice)
                .cornerRadius(50)
            Text(dateString)
                .font(.system(size: 10))
                .foregroundColor(.bgWh)
        }
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
