//
//  ChatData.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation

struct ChatData: Hashable, Identifiable {
    var dateString: String
    var chats: [Chat]
    var id: String { dateString }
}
