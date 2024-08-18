//
//  Constant.swift
//  Lproject
//
//  Created by Jaehwi Kim on 8/18/24.
//

import Foundation

typealias DBKey = Constant.DBKey

// Namespace
enum Constant { }

extension Constant {
    struct DBKey {
        static let Users = "Users"
        static let ChatRooms = "ChatRooms"
        static let Chats = "Chats"
    }
}
