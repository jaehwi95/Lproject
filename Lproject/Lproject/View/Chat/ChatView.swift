//
//  ChatView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    ChatView(viewModel: .init(chatRoomId: "chatRoom1_id", myUserId: "user1_id", otherUserId: "user2_id", container: DIContainer(services: StubService())))
}
