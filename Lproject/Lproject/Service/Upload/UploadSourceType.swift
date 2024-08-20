//
//  UploadSourceType.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/20.
//

import Foundation

enum UploadSourceType {
    case chat(chatRoomId: String)
    case profile(userId: String)
    
    var path: String {
        switch self {
        case let .chat(chatRoomId: chatRoomId): // Chats/chatRoomId/
            return "\(DBKey.Chats)/\(chatRoomId)"
        case let .profile(userId: userId): // Users/UserId/
            return "\(DBKey.Users)/\(userId)"
        }
    }
}
