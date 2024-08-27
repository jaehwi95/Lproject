//
//  ChatViewModel.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    enum Action {
        
    }
    
    @Published var chatDataList: [ChatData] = []
    @Published var myUser: User?
    @Published var otherUser: User?
    @Published var message: String = ""
    
    private let chatRoomId: String
    private let myUserId: String
    private let otherUserId: String
    
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(chatRoomId: String, myUserId: String, otherUserId: String, container: DIContainer) {
        self.chatRoomId = chatRoomId
        self.myUserId = myUserId
        self.otherUserId = otherUserId
        self.container = container
    }
    
    func updateChatDataList(_ chat: Chat) {
        let key = chat.date.toChatDateKey
        if let index = chatDataList.firstIndex(where: { $0.dateString == key }) {
            chatDataList[index].chats.append(chat)
        } else {
            let newChatData: ChatData = .init(dateString: key, chats: [chat])
            chatDataList.append(newChatData)
        }
    }
    
    func getDirection(id: String) -> ChatItemDirection {
        myUserId == id ? .right : .left
    }
    
    func send(action: Action) {
        
    }
}
