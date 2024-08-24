//
//  ChatRoom.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation

struct ChatRoom: Hashable {
    var chatRoomId: String
    var lastMessage: String?
    var otherUserName: String
    var otherUserId: String
}

extension ChatRoom {
    func toObject() -> ChatRoomObject {
        .init(
            chatRoomId: chatRoomId,
            lastMessage: lastMessage,
            otherUserName: otherUserName,
            otherUserId: otherUserId
        )
    }
}

extension ChatRoom {
    static var stub1: ChatRoom {
        .init(chatRoomId: "chatRoom1_id", otherUserName: "김재휘", otherUserId: "user1_id")
    }
    
    static var stub2: ChatRoom {
        .init(chatRoomId: "chatRoom2_id", otherUserName: "안유진", otherUserId: "user2_id")
    }
}
