//
//  Chat.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation

struct Chat: Hashable {
    var chatId: String
    var userId: String
    var message: String?
    var photoURL: String?
    var date: Date
}
